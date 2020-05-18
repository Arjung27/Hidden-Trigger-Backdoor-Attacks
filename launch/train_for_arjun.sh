#!/bin/bash

# Lines that begin with #SBATCH specify commands to be used by SLURM for scheduling
#SBATCH --job-name=train                            # sets the job name if not set from environment
#SBATCH --array=1                                 # Submit 8 array jobs, throttling to 4 at a time
#SBATCH --output cmllogs/%x_%A_%a.log                   # redirect STDOUT to; %j is the jobid, _%A_%a is array task id
#SBATCH --error cmllogs/%x_%A_%a.log                    # redirect STDERR to; %j is the jobid,_%A_%a is array task id
#SBATCH --account=tomg                            # set QOS, this will determine what resources can be requested
#SBATCH --qos=medium                                # set QOS, this will determine what resources can be requested
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=4
#SBATCH --partition=dpart
#SBATCH --mem 16gb                                      # memory required by job; MB will be assumed
#SBATCH --mail-user avi1@umd.edu
#SBATCH --mail-type=END,TIME_LIMIT,FAIL,ARRAY_TASKS
#SBATCH --time=08:00:00                                 # how long will the job will take to complete; format=hh:mm:ss


#python train_model.py --seed 1000 --model resnet18 --epochs 200 --lr 0.1 --lr_factor 0.1 --lr_schedule 100 150 --optimizer SGD --checkpoint /cmlscratch/avi1/my_model_chks --save_net --output my_models_output

#python train_model.py --seed 1000 --model DenseNet121 --epochs 200 --lr 0.1 --lr_factor 0.1 --lr_schedule 100 150 --optimizer SGD --checkpoint /cmlscratch/avi1/my_model_chks --save_net --output my_models_output

python train_model.py --seed 1000 --model MobileNetV2 --epochs 200 --lr 0.1 --lr_factor 0.1 --lr_schedule 100 150 --optimizer SGD --checkpoint /cmlscratch/avi1/my_model_chks --save_net --output my_models_output
