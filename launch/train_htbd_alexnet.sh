#!/bin/bash

# Lines that begin with #SBATCH specify commands to be used by SLURM for scheduling
#SBATCH --job-name=htbd                            # sets the job name if not set from environment
#SBATCH --array=1                                 # Submit 8 array jobs, throttling to 4 at a time
#SBATCH --output cmllogs/%x_%A_%a.log                   # redirect STDOUT to; %j is the jobid, _%A_%a is array task id
#SBATCH --error cmllogs/%x_%A_%a.log                    # redirect STDERR to; %j is the jobid,_%A_%a is array task id
#SBATCH --account=scavenger                           # set QOS, this will determine what resources can be requested
#SBATCH --qos=scavenger                                 # set QOS, this will determine what resources can be requested
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=4
#SBATCH --partition=scavenger
#SBATCH --mem 16gb                                      # memory required by job; MB will be assumed
#SBATCH --mail-user arjung15@umd.edu
#SBATCH --mail-type=END,TIME_LIMIT,FAIL,ARRAY_TASKS
#SBATCH --time=10:00:00                                 # how long will the job will take to complete; format=hh:mm:ss

seed=$((1000 + $SLURM_ARRAY_TASK_ID))

checkpoint="/cmlscratch/arjgpt27/my_model_chks/htbd_alexnet_normalized"
# modelpath="${checkpoint}/htbd_alexnet_seed_${seed}_normalize=True_augment=False_optimizer=adam_epoch=199.t7"
output_dir="htbd_alexnet_chkpoints"

# echo " "
# echo "mkdir -p ${output_dir}"
# mkdir -p $output_dir
# echo " "
# echo "Training HTBDAlexNet."
# python train_model.py --seed ${seed} --model htbd_alexnet --epochs 200 --lr 0.001 --lr_factor 0.5 --lr_schedule 32 64 96 128 160 192 --optimizer adam --checkpoint $checkpoint --save_net --output $output_dir --normalize
# python test_model.py --model htbd_alexnet --normalize --output $output_dir --model_path $modelpath
# echo "Training and testing complete."
# echo " "

# modelpath="${checkpoint}/htbd_alexnet32_seed_${seed}_normalize=True_augment=False_optimizer=adam_epoch=199.t7"

# echo " "
# echo "mkdir -p ${output_dir}"
# mkdir -p $output_dir
# echo " "
# echo "Training HTBDAlexNet."
# python train_model.py --seed ${seed} --model htbd_alexnet32 --epochs 200 --lr 0.001 --lr_factor 0.5 --lr_schedule 32 64 96 128 160 192 --optimizer adam --checkpoint $checkpoint --save_net --output $output_dir --normalize
# python test_model.py --model htbd_alexnet32 --normalize --output $output_dir --model_path $modelpath
# echo "Training and testing complete."
# echo " "

modelpath="${checkpoint}/htbd_alexnet128_seed_${seed}_normalize=True_augment=False_optimizer=adam_epoch=199.t7"

echo " "
echo "mkdir -p ${output_dir}"
mkdir -p $output_dir
echo " "
echo "Training HTBDAlexNet."
python train_model.py --seed ${seed} --model htbd_alexnet128 --epochs 200 --lr 0.001 --lr_factor 0.5 --lr_schedule 32 64 96 128 160 192 --optimizer adam --checkpoint $checkpoint --save_net --output $output_dir --normalize
python test_model.py --model htbd_alexnet128 --normalize --output $output_dir --model_path $modelpath
echo "Training and testing complete."
echo " "

modelpath="${checkpoint}/htbd_alexnet256_seed_${seed}_normalize=True_augment=False_optimizer=adam_epoch=199.t7"

echo " "
echo "mkdir -p ${output_dir}"
mkdir -p $output_dir
echo " "
echo "Training HTBDAlexNet."
python train_model.py --seed ${seed} --model htbd_alexnet256 --epochs 200 --lr 0.001 --lr_factor 0.5 --lr_schedule 32 64 96 128 160 192 --optimizer adam --checkpoint $checkpoint --save_net --output $output_dir --normalize
python test_model.py --model htbd_alexnet256 --normalize --output $output_dir --model_path $modelpath
echo "Training and testing complete."
echo " "
