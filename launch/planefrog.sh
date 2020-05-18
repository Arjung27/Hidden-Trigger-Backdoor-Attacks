#!/bin/bash

# Lines that begin with #SBATCH specify commands to be used by SLURM for scheduling
#SBATCH --job-name=planefrog                            # sets the job name if not set from environment
#SBATCH --array=1-100                                  # Submit 8 array jobs, throttling to 4 at a time
#SBATCH --output cmllogs/%x_%A_%a.log                   # redirect STDOUT to; %j is the jobid, _%A_%a is array task id
#SBATCH --error cmllogs/%x_%A_%a.log                    # redirect STDERR to; %j is the jobid,_%A_%a is array task id
#SBATCH --account=scavenger                           # set QOS, this will determine what resources can be requested
#SBATCH --qos=scavenger                                 # set QOS, this will determine what resources can be requested
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=4
#SBATCH --partition=scavenger
#SBATCH --mem 16gb                                      # memory required by job; MB will be assumed
#SBATCH --mail-user avi1@umd.edu
#SBATCH --mail-type=END,TIME_LIMIT,FAIL,ARRAY_TASKS
#SBATCH --time=05:00:00                                 # how long will the job will take to complete; format=hh:mm:ss

# Baseline Alexnet
echo "running..."
python one_random_trial.py \
--num_poisons 50 \
--watermark_coeff 0.3 \
--poisons_path /cmlscratch/avi1/poisons/alexnet/${SLURM_ARRAY_TASK_ID} \
--model_dir /cmlscratch/avi1/my_model_chks/alexnet \
--crafting_iters 12000 \
--model alexnet \
--output alexnet_plane_frog_output_wb \
--no-normalize \
--optimizer adam \
--lr 0.00015625 \
--epochs 10 \
--val_period 10 \
--end2end \
--grey_box \
--black_box \
--black_box_model resnet18 \
--black_box_model_dir /cmlscratch/avi1/my_model_chks/resnet18_augment \
--black_box_normalize \
--black_box_augment \
--poisoned_label 6 \
--target_class 0

echo "Done."

# Alexnet with normalization
echo "running..."
python one_random_trial.py \
--num_poisons 50 \
--watermark_coeff 0.3 \
--poisons_path /cmlscratch/avi1/poisons/alexnetnorm/${SLURM_ARRAY_TASK_ID} \
--model_dir /cmlscratch/avi1/my_model_chks/alexnet_normalized \
--crafting_iters 12000 \
--model alexnet \
--output alexnetnorm_plane_frog_output_wb \
--normalize \
--optimizer adam \
--lr 0.00015625 \
--epochs 10 \
--val_period 10 \
--end2end \
--grey_box \
--black_box \
--black_box_model resnet18 \
--black_box_model_dir /cmlscratch/avi1/my_model_chks/resnet18_augment \
--black_box_normalize \
--black_box_augment \
--poisoned_label 6 \
--target_class 0

echo "Done."

# Alexnet with augmentation
echo "running..."
python one_random_trial.py \
--num_poisons 50 \
--watermark_coeff 0.3 \
--poisons_path /cmlscratch/avi1/poisons/alexnetaug/${SLURM_ARRAY_TASK_ID} \
--model_dir /cmlscratch/avi1/my_model_chks/alexnet_augment \
--crafting_iters 12000 \
--model alexnet \
--output alexnetaug_plane_frog_output_wb \
--normalize \
--train_augment \
--optimizer adam \
--lr 0.00015625 \
--epochs 10 \
--val_period 10 \
--end2end \
--grey_box \
--black_box \
--black_box_model resnet18 \
--black_box_model_dir /cmlscratch/avi1/my_model_chks/resnet18_augment \
--black_box_normalize \
--black_box_augment \
--poisoned_label 6 \
--target_class 0

echo "Done."

# Alexnet with sgd
echo "running..."
python one_random_trial.py \
--num_poisons 50 \
--watermark_coeff 0.3 \
--poisons_path /cmlscratch/avi1/poisons/alexnetsgd/${SLURM_ARRAY_TASK_ID} \
--model_dir /cmlscratch/avi1/my_model_chks/alexnet_sgd \
--crafting_iters 12000 \
--model alexnet \
--output alexnetsgd_plane_frog_output_wb \
--normalize \
--train_augment \
--optimizer SGD \
--lr 0.001 \
--epochs 10 \
--val_period 10 \
--end2end \
--grey_box \
--black_box \
--black_box_model resnet18 \
--black_box_model_dir /cmlscratch/avi1/my_model_chks/resnet18_augment \
--black_box_normalize \
--black_box_augment \
--poisoned_label 6 \
--target_class 0

echo "Done."
