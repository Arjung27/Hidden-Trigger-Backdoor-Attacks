#!/bin/bash

# Lines that begin with #SBATCH specify commands to be used by SLURM for scheduling
#SBATCH --job-name=frogs_arr                            # sets the job name if not set from environment
#SBATCH --array=1-200                               # Submit 8 array jobs, throttling to 4 at a time
#SBATCH --output cmllogs/%x_%A_%a.log                   # redirect STDOUT to; %j is the jobid, _%A_%a is array task id
#SBATCH --error cmllogs/%x_%A_%a.log                    # redirect STDERR to; %j is the jobid,_%A_%a is array task id
#SBATCH --account=scavenger                            # set QOS, this will determine what resources can be requested
#SBATCH --qos=scavenger                                # set QOS, this will determine what resources can be requested
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=4
#SBATCH --partition=scavenger
#SBATCH --mem 16gb                                      # memory required by job; MB will be assumed
#SBATCH --mail-user avi1@umd.edu
#SBATCH --mail-type=END,TIME_LIMIT,FAIL,ARRAY_TASKS
#SBATCH --time=03:00:00                                 # how long will the job will take to complete; format=hh:mm:ss


##############
# This is the baseline
##############
#checkpoint="/cmlscratch/avi1/my_model_chks/"
#modelpath="/cmlscratch/avi1/my_model_chks/alexnet_seed_1000_normalize=False_augment=False_optimizer=adam_epoch=199.t7"
#poisonpath="/cmlscratch/avi1/poisons/frogsout_${SLURM_ARRAY_TASK_ID}"
#output_dir="alexnet_unnormalized"
#targetclass=2
#baseclass=5
#opacity=0.3
#
#echo " "
#echo "mkdir -p ${output_dir}"
#mkdir -p $output_dir
#echo " "
#echo "Training AlexNetFrogs."
#python train_model.py --seed 1000 --model alexnet --epochs 200 --lr 0.001 --lr_factor 0.5 --lr_schedule 32 64 96 128 160 192 --optimizer adam --checkpoint $checkpoint --save_net --output $output_dir --no-normalize
#python test_model.py --model alexnet --no-normalize --output $output_dir --model_path $modelpath
#echo "Training and testing complete."
#echo " "
#echo "Testing PoisonFrogs attack."
#python craft_poisons_frogs.py --num_poisons 50 --watermark_coeff $opacity --poisons_path $poisonpath --model_path $modelpath --target_class $targetclass --poisoned_label $baseclass --target_img_idx ${SLURM_ARRAY_TASK_ID} --crafting_iters 12000 --model alexnet --output $output_dir --no-normalize
#python poison_test.py --poisons_path $poisonpath --model alexnet --optimizer adam --lr 0.00015625 --model_path $modelpath --epochs 10 --val_period 1 --output $output_dir --poisoned_label $baseclass --no-normalize --end2end
#echo "Done testing poison frogs."

##############
# This is with normalization
##############
checkpoint="/cmlscratch/avi1/my_model_chks/"
modelpath="/cmlscratch/avi1/my_model_chks/alexnet_seed_4444_normalize=True_augment=False_optimizer=adam_epoch=199.t7"
poisonpath="/cmlscratch/avi1/poisons/frogsout_${SLURM_ARRAY_TASK_ID}"
output_dir="alexnet_normalized"
targetclass=2
baseclass=5
opacity=0.3

#echo " "
#echo "mkdir -p ${output_dir}"
#mkdir -p $output_dir
#echo " "
#echo "Training AlexNetFrogs."
#python train_model.py --seed 4444 --model alexnet --epochs 200 --lr 0.001 --lr_factor 0.5 --lr_schedule 32 64 96 128 160 192 --optimizer adam --checkpoint $checkpoint --save_net --output $output_dir --normalize
#python test_model.py --model alexnet --normalize --output $output_dir --model_path $modelpath
#echo "Training and testing complete."
echo " "
echo "Testing PoisonFrogs attack."
python craft_poisons_frogs.py --num_poisons 50 --watermark_coeff $opacity --poisons_path $poisonpath --model_path $modelpath --target_class $targetclass --poisoned_label $baseclass --target_img_idx ${SLURM_ARRAY_TASK_ID} --crafting_iters 12000 --model alexnet --output $output_dir --normalize
python poison_test.py --poisons_path $poisonpath --model alexnet --optimizer adam --lr 0.00015625 --model_path $modelpath --epochs 10 --val_period 1 --output $output_dir --poisoned_label $baseclass --normalize --end2end
echo "Done testing poison frogs."

###############
## This is with normalization
###############
#modelpath="/cmlscratch/avi1/my_model_chks/alexnet_seed_1000_normalize=True_epoch=199.t7"
#poisonpath="/cmlscratch/avi1/poisons/frogsout_${SLURM_ARRAY_TASK_ID}"
#output_dir="alexnet_normalized"
#targetclass=2
#baseclass=5
#opacity=0.3
#
#echo " "
#echo "mkdir -p ${output_dir}"
#mkdir -p $output_dir
#echo " "
##echo "Training AlexNetFrogs."
##python train_model.py --seed 1000 --model alexnet --epochs 200 --lr 0.001 --lr_factor 0.5 --lr_schedule 32 64 96 128 160 192 --optimizer adam --checkpoint /cmlscratch/avi1/my_model_chks --save_net --output $output_dir --normalize
##python test_model.py --model alexnet --normalize --output $output_dir --model_path $modelpath
##echo "Training and testing complete."
#echo " "
#echo "Testing PoisonFrogs attack."
#python craft_poisons_frogs.py --num_poisons 50 --watermark_coeff $opacity --poisons_path $poisonpath --model_path $modelpath --target_class $targetclass --poisoned_label $baseclass --target_img_idx ${SLURM_ARRAY_TASK_ID} --crafting_iters 12000 --model alexnet --output $output_dir --normalize
#python poison_test.py --poisons_path $poisonpath --model alexnet --optimizer adam --lr 0.0001 --lr_factor 0.1 --lr_schedule 10 --model_path $modelpath --epochs 20 --val_period 10 --output $output_dir --poisoned_label $baseclass --normalize
#echo "Done testing poison frogs."
#
###############
## This is with augmentation (no normalization)
###############
#modelpath="/cmlscratch/avi1/my_model_chks_augment/alexnet_seed_1000_normalize=False_epoch=299.t7"
#poisonpath="/cmlscratch/avi1/poisons/frogsout_${SLURM_ARRAY_TASK_ID}"
#output_dir="alexnet_augment"
#targetclass=2
#baseclass=5
#opacity=0.3
#
#echo " "
#echo "mkdir -p ${output_dir}"
#mkdir -p $output_dir
#echo " "
##echo "Training AlexNetFrogs."
##python train_model.py --seed 1000 --model alexnet --epochs 300 --lr 0.001 --lr_factor 0.5 --lr_schedule 32 64 96 128 160 192 224 256 288 --optimizer adam --checkpoint /cmlscratch/avi1/my_model_chks_augment --save_net --output $output_dir --no-normalize --train_augment
##python test_model.py --model alexnet --no-normalize --train_augment --output $output_dir --model_path $modelpath
##echo "Training and testing complete."
#echo " "
#echo "Testing PoisonFrogs attack."
#python craft_poisons_frogs.py --num_poisons 50 --watermark_coeff $opacity --poisons_path $poisonpath --model_path $modelpath --target_class $targetclass --poisoned_label $baseclass --target_img_idx ${SLURM_ARRAY_TASK_ID} --crafting_iters 12000 --model alexnet --output $output_dir --no-normalize
#python poison_test.py --poisons_path $poisonpath --model alexnet --optimizer adam --lr 0.0001 --lr_factor 0.1 --lr_schedule 10 30 --model_path $modelpath --epochs 50 --val_period 5 --output $output_dir --poisoned_label $baseclass --no-normalize --train_augment
#echo "Done testing poison frogs."

###############
## This is with SGD and --lr 0.1 --lr_factor 0.1 --lr_schedule 100 150 AND normalization AND augmentation
###############
#modelpath="/cmlscratch/avi1/my_model_chks_all/alexnet_seed_1000_normalize=False_epoch=199.t7"
#poisonpath="/cmlscratch/avi1/poisons/frogsout_${SLURM_ARRAY_TASK_ID}"
#output_dir="alexnet_all"
#targetclass=2
#baseclass=5
#opacity=0.3
#
#echo " "
#echo "mkdir -p ${output_dir}"
#mkdir -p $output_dir
#echo " "
#echo "Training AlexNetFrogs."
#python train_model.py --seed 1000 --model alexnet --epochs 200 --lr 0.1 --lr_factor 0.1 --lr_schedule 100 150 --optimizer SGD --checkpoint /cmlscratch/avi1/my_model_chks_all --save_net --output $output_dir --normalize --train_augment
#python test_model.py --model alexnet --normalize --train_augment --output $output_dir --model_path $modelpath
#echo "Training and testing complete."
#echo " "
#echo "Testing PoisonFrogs attack."
#python craft_poisons_frogs.py --num_poisons 50 --watermark_coeff $opacity --poisons_path $poisonpath --model_path $modelpath --target_class $targetclass --poisoned_label $baseclass --target_img_idx ${SLURM_ARRAY_TASK_ID} --crafting_iters 12000 --model alexnet --output $output_dir --normalize
#python poison_test.py --poisons_path $poisonpath --model alexnet --optimizer SGD --lr 0.001 --model_path $modelpath --epochs 10 --end2end --val_period 10 --output $output_dir --poisoned_label $baseclass --normalize --train_augment
#echo "Done testing poison frogs."
