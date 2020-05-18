#!/bin/bash

# Lines that begin with #SBATCH specify commands to be used by SLURM for scheduling
#SBATCH --job-name=poly                                 # sets the job name if not set from environment
#SBATCH --array=1-20                                    # Submit 8 array jobs, throttling to 4 at a time
#SBATCH --output cmllogs/%x_%A_%a.log                   # redirect STDOUT to; %j is the jobid, _%A_%a is array task id
#SBATCH --error cmllogs/%x_%A_%a.log                    # redirect STDERR to; %j is the jobid,_%A_%a is array task id
#SBATCH --time=12:00:00                                 # how long will the job will take to complete; format=hh:mm:ss
#SBATCH --account=scavenger                             # set QOS, this will determine what resources can be requested
#SBATCH --qos=scavenger                                 # set QOS, this will determine what resources can be requested
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=1
#SBATCH --partition=scavenger
#SBATCH --mem 16gb                                      # memory required by job; MB will be assumed
#SBATCH --mail-user avi1@umd.edu
#SBATCH --mail-type=END,TIME_LIMIT,FAIL,ARRAY_TASKS

echo "Testing ConvexPolytope attack."

echo "mkdir logs/poly/${SLURM_ARRAY_TASK_ID}"
mkdir -p logs/poly

PP="/cmlscratch/avi1/polytope_${SLURM_ARRAY_TASK_ID}"

# python craft_poisons_polytope.py --num_poisons 5 --poisons_path $PP --gpu 0 --subs-chk-name ckpt-%s-4800-dp0.200-droplayer0.000-seed1226.t7 ckpt-%s-4800-dp0.250-droplayer0.000-seed1226.t7 ckpt-%s-4800-dp0.300-droplayer0.000.t7 --subs-dp 0.2 0.25 0.3  --substitute-nets DPN92 SENet18 ResNet50 ResNeXt29_2x64d --target-index 1 --target-label 6 --poison-label 8
python poison_test.py --poisons_path $PP --model DenseNet121 --model_path polytope/model-chks/cifar10-ckpt-DenseNet121-4800to2400-dp0.000-droplayer0.000-seed1226-latest.t7 --epochs 20 --val_period 10 --output logs/poly --poisoned_label 8

echo "Done testing convex polytope."