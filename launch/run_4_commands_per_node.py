from pbs_job_launch import submit_job
import os
import argparse
import datetime

# YOU SHOULD CUSTOMIZE THE FOLLOWING VARIABLES FOR YOUR JOB!
my_repo_name = "poison-attacks"  # Put your git repo name here
task_name = "psn"  # Put a short (<6 chars) and unique name here - The queue manager uses this name to identify jobs
command_file = "hokulea.sh"  # The path of a file containing a like of jobs
hours = 1  # Max hours the job can run.  You can choose at MOST 120.
redirect_to_log = True  # If true, automatically add redirection to a logfile after every command. I.e., "&> logfile.out"


# A flag to determine whether to submit these jobs on Hokulea as the PBS scripts are generated.
# Submission is False by default, but let's make it easy for Tom to turn it on when calling this script on Hokulea
parser = argparse.ArgumentParser(description='Make Hokulea jobs')
parser.add_argument('--submit', action='store_true', default=False,
                    help='Submit these jobs as they are generated')
args = parser.parse_args()
submit_jobs = args.submit

# A list of options for pbs_job_launch
opts = {"hours": hours,  # SPECIFY JOB RUNTIME HERE (120 hrs max)
        "mins": 30,
        "secs": 0,
        "account": "MHPCC96670DA1",  # "USNAM37766Z80",
        "num_nodes": 1,
        "procs_per_node": 1,
        "cpus_per_node": 20,
        "queue": "standard",
        "delete_after_submit": False,  # Delete the pbs shell script immediately after calling qsub?
        "call_qsub": submit_jobs
        }

# After your job boots up, it will call this command to setup the environment.
# You can add things to the setup command, but usually the default below is all
# you need.
opts["setup_command"] = \
    """
cd /gpfs/scratch/tomg  # move into the work folder where I keep all the repos
cd {my_repo} # Move into the directory for your repo
""".format(my_repo=my_repo_name)

# After your jobs completes, sync results to tricky
opts["cleanup_command"] = \
    f"""
    cd /gpfs/scratch/tomg  # move into the work folder where I keep all the repos
    chmod -R  ugo+rwx {my_repo_name}
    rsync -rvz -e 'ssh -p 9876' --exclude=".*" --exclude="data/" {my_repo_name}/ tom@localhost:/home/shared/{my_repo_name}
    """

# The location to save the launch scripts.
output_dir = "scripts/"
os.makedirs(output_dir, exist_ok=True)
opts["outfile_prefix"] = os.path.abspath(output_dir) + '/'

# Read a file with a list of jobs
with open(command_file) as f:
    content = f.readlines()

# Remove all lines from the docs that don't contain "python" (i.e, comments or other text)
jobs = [c.strip() for c in content if 'python' in c]
# Remove all lines that contain comments
jobs = [c for c in jobs if not c[0] == '#']

# Make sure the number if jobs is divisible by 8.  The loop below assumes this.
while len(jobs) % 8 > 0:
    jobs.append('echo "Place holder job"')

print("Launching jobs: %d" % len(jobs))

now = datetime.datetime.now()
date_tag = f'__{now.month}.{now.day}.{now.hour}'

# This loop will create a job for every batch of 4 commands, and launch it.
# Note that I wait for each job to end - otherwise the script will terminate
# Immediately after setting off the last job (i.e., before the jobs terminate).
for i in range(0, len(jobs), 8):
    cmd0 = jobs[i + 0]
    cmd1 = jobs[i + 1]
    cmd2 = jobs[i + 2]
    cmd3 = jobs[i + 3]
    cmd4 = jobs[i + 4]
    cmd5 = jobs[i + 5]
    cmd6 = jobs[i + 6]
    cmd7 = jobs[i + 7]
    opts["job_name"] = task_name + str(i // 4)
    if redirect_to_log:
        logfile_name = opts["outfile_prefix"] + opts["job_name"]
        cmd0 = cmd0 + " &> " + logfile_name + "_task0" + date_tag + ".log"
        cmd1 = cmd1 + " &> " + logfile_name + "_task1" + date_tag + ".log"
        cmd2 = cmd2 + " &> " + logfile_name + "_task2" + date_tag + ".log"
        cmd3 = cmd3 + " &> " + logfile_name + "_task3" + date_tag + ".log"
        cmd4 = cmd4 + " &> " + logfile_name + "_task4" + date_tag + ".log"
        cmd5 = cmd5 + " &> " + logfile_name + "_task5" + date_tag + ".log"
        cmd6 = cmd6 + " &> " + logfile_name + "_task6" + date_tag + ".log"
        cmd7 = cmd7 + " &> " + logfile_name + "_task7" + date_tag + ".log"

    command = f"""
    CUDA_VISIBLE_DEVICES=0 {cmd0} && CUDA_VISIBLE_DEVICES=0 {cmd1}  &
    pid0=$!
    CUDA_VISIBLE_DEVICES=1 {cmd2} && CUDA_VISIBLE_DEVICES=1 {cmd3}  &
    pid1=$!
    CUDA_VISIBLE_DEVICES=2 {cmd4} && CUDA_VISIBLE_DEVICES=2 {cmd5}  &
    pid2=$!
    CUDA_VISIBLE_DEVICES=3 {cmd6} && CUDA_VISIBLE_DEVICES=3 {cmd7}  &
    pid3=$!
    wait $pid0
    wait $pid1
    wait $pid2
    wait $pid3
    """

    submit_job(command, **opts)
