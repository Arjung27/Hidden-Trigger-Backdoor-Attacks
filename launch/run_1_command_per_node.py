from pbs_job_launch import submit_job
import os
import argparse
import datetime

# YOU SHOULD CUSTOMIZE THE FOLLOWING VARIABLES FOR YOUR JOB!
my_repo_name = "forest"  # Put your git repo name here
task_name = "imgnt"  # Put a short (<6 chars) and unique name here - The queue manager uses this name to identify jobs
command_file = "imagenet_runs_hokulea.sh"  # The path of a file containing a like of jobs
hours = 45  # Max hours the job can run.  You can choose at MOST 120.
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
        "mins": 0,
        "secs": 0,
        "account": "MHPCC96670DA1",  # "USNAM37766Z80", MU8MHPCC96670DA1
        "num_nodes": 1,
        "procs_per_node": 4,
        "cpus_per_node": 20,
        "queue": "standard",
        "delete_after_submit": False,  # Delete the pbs shell script immediately after calling qsub?
        "call_qsub": submit_jobs
        }

# After your job boots up, it will call this command to setup the environment.
# You can add things to the setup command, but usually the default below is all
# you need.
opts["setup_command"] = \
f"""
cd /gpfs/scratch/tomg   # move into the work folder where I keep all the repos
cd {my_repo_name} # Move into the directory for your repo
"""

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
# Remove all lines that comtain comments
jobs = [c for c in jobs if not c[0] == '#']

print("Launching jobs: %d" % len(jobs))
now = datetime.datetime.now()
date_tag = f'__{now.month}.{now.day}.{now.hour}'

for i in range(0, len(jobs)):
    command = jobs[i]
    opts["job_name"] = task_name + str(i) + date_tag
    if redirect_to_log:
        logfile_name = opts["outfile_prefix"] + opts["job_name"] + ".log"
        command = command + " &> " + logfile_name

    submit_job(command, **opts)
