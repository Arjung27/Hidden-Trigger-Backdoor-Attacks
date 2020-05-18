import argparse
import os
import subprocess
import time
import warnings
import getpass
import random

parser = argparse.ArgumentParser(description='Dispatch a list of python jobs from file to the CML cluster')

# Central:
parser.add_argument('file', type=argparse.FileType())
parser.add_argument('--test', action="store_true", help='Dont launch, just test the launch and print information')
parser.add_argument('--min_preemptions', action='store_true', help='Launch only on nodes with no scavenger jobs.')

parser.add_argument('--qos', default='scav', type=str, help='QOS, choose default, medium, high, scav')
parser.add_argument('--name', default=None, type=str, help='Name that will be displayed in squeue. Default: file name')
parser.add_argument('--gpus', default='1', type=int, help='Requested GPUs per job')
parser.add_argument('--mem', default='24', type=int, help='Requested memory per job')
parser.add_argument('--timelimit', default=48, type=int, help='Requested hour limit per job')
parser.add_argument('--throttling', default=None, type=int, help='Launch only this many jobs concurrently')
args = parser.parse_args()


# Parse and validate input:
if args.name is None:
    dispatch_name = args.file.name
else:
    dispatch_name = args.name

# Usage warnings:
if args.mem > 385:
    raise ValueError('Maximal node memory exceeded.')
if args.gpus > 8:
    raise ValueError('Maximal node GPU number exceeded.')
if args.qos == 'high' and args.gpus > 4:
    warnings.warn('QOS only allows for 4 GPUs, GPU request has been reduced to 4.')
    args.gpus = 4
if args.qos == 'medium' and args.gpus > 2:
    warnings.warn('QOS only allows for 2 GPUs, GPU request has been reduced to 2.')
    args.gpus = 2
if args.qos == 'default' and args.gpus > 1:
    warnings.warn('QOS only allows for 1 GPU, GPU request has been reduced to 1.')
    args.gpus = 1
if args.mem / args.gpus > 48:
    warnings.warn('You are oversubscribing to memory. This might leave some GPUs idle as total node memory is consumed.')

# 1) Stripping file of comments and blank lines
content = args.file.readlines()
jobs = [c.strip().split('#', 1)[0] for c in content if 'python' in c and c[0] != '#']

# 2) Decide which nodes not to use in scavenger:
username = getpass.getuser()
tomsgroup = ['aminjun', 'ashafahi', 'chenzhu', 'goldblum', 'lfowl', 'parsa', 'pchiang', 'rhuang', 'tomg', 'xuzh',
             'zeyad', 'pepope', 'avi1', 'jonas0']  # this could be automated via "sshare -a | grep tomg"

# Remove your own name, so that node usage is improved among your own jobs.
if username in tomsgroup and not args.min_preemptions:
    tomsgroup.remove(username)

all_nodes = set(f'cml0{i}' for i in range(10))
banned_nodes = set()

if args.min_preemptions:
    try:
        raw_status = subprocess.run("squeue", capture_output=True)
        cluster_status = [s.split() for s in str(raw_status.stdout).split('\\n')]
        for sjob in cluster_status[1:-1]:
            if sjob[1] == 'scavenger' and sjob[3] in tomsgroup and 'cml' in sjob[-1]:
                banned_nodes.add(sjob[-1])
    except FileNotFoundError:
        print('Node exclusion only works when called on cml nodes.')
node_list = sorted(all_nodes - banned_nodes)
banned_nodes = sorted(banned_nodes)

print(f'Detected {len(jobs)} jobs.')

# Write file list
authkey = random.randint(10**5, 10**6 - 1)
with open(f".cml_job_list_{authkey}.temp.sh", "w") as file:
    file.writelines(chr(10).join(job for job in jobs))
    file.write("\n")


# 3) Prepare environment
if not os.path.exists('cmllogs'):
    os.makedirs('cmllogs')

# 4) Construct launch file
SBATCH_PROTOTYPE = \
    f"""#!/bin/bash

# Lines that begin with #SBATCH specify commands to be used by SLURM for scheduling
#SBATCH --job-name={''.join(e for e in dispatch_name if e.isalnum())}
#SBATCH --array={f"1-{len(jobs)}" if args.throttling is None else f"1-{len(jobs)}%{args.throttling}"}
#SBATCH --output=cmllogs/%x_%A_%a.log
#SBATCH --error=cmllogs/%x_%A_%a.log
#SBATCH --time={args.timelimit}:00:00
#SBATCH --account={"tomg" if args.qos != "scav" else "scavenger"}
#SBATCH --qos={args.qos if args.qos != "scav" else "scavenger"}
#SBATCH --gres=gpu:{args.gpus}
#SBATCH --cpus-per-task=1
#SBATCH --partition={"dpart" if args.qos != "scav" else "scavenger"}
{f"#SBATCH --exclude={','.join(str(node) for node in banned_nodes)}" if banned_nodes else ''}
#SBATCH --mem={args.mem}gb
#SBATCH --mail-user=avi1@umd.edu
#SBATCH --mail-type=END,TIME_LIMIT,FAIL,ARRAY_TASKS

srun $(head -n $((${{SLURM_ARRAY_TASK_ID}} + 0)) .cml_job_list_{authkey}.temp.sh | tail -n 1)
"""

# Write launch commands to file
with open(f".cml_launch_{authkey}.temp.sh", "w") as file:
    file.write(SBATCH_PROTOTYPE)

print('Launch prototype is ...')
print('---------------')
print(SBATCH_PROTOTYPE)
print('---------------')
print(chr(10).join('srun ' + job for job in jobs))
print(f'Preparing {len(jobs)} jobs as user {username}'
      f' for launch on nodes {",".join(str(node) for node in node_list)} in 10 seconds...')
print('Terminate if necessary ...')
for _ in range(10):
    time.sleep(1)


if not args.test:
    # Execute file with sbatch
    subprocess.run(["/usr/bin/sbatch", f".cml_launch_{authkey}.temp.sh"])
    print('Subprocess launched ...')
    time.sleep(3)
    os.system("squeue -u avi1")
else:
    try:
        # Execute file with sbatch in test-only mode, no jobs are submitted
        subprocess.run(["/usr/bin/sbatch", f".cml_launch_{authkey}.temp.sh", " --test-only"])
        print('Subprocess launched ...')
        time.sleep(3)
        os.system("squeue -u avi1")
    except FileNotFoundError:
        print('Allocation testing only works when called on cml nodes.')
    print('Test concluded.')
