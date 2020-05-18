#!/bin/bash

# Lines that begin with #SBATCH specify commands to be used by SLURM for scheduling
#SBATCH --job-name=mobilenet                            # sets the job name if not set from environment
#SBATCH --array=1-10                                  # Submit 8 array jobs, throttling to 4 at a time
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
#SBATCH --time=08:00:00                                 # how long will the job will take to complete; format=hh:mm:ss

seed=$((1000 + $SLURM_ARRAY_TASK_ID))

checkpoint="/cmlscratch/avi1/my_model_chks/mobilenet_notnormalized"
modelpath="${checkpoint}/MobileNetV2_seed_${seed}_normalize=False_augment=False_optimizer=SGD_epoch=199.t7"
output_dir="mobilenet_chkpoints"

echo " "
echo "mkdir -p ${output_dir}"
mkdir -p $output_dir
echo " "
echo "Training MobileNetV2."
python train_model.py --seed ${seed} --model MobileNetV2 --epochs 200 --lr 0.1 --lr_factor 0.1 --lr_schedule 100 150 --optimizer SGD --checkpoint $checkpoint --save_net --output $output_dir --no-normalize
python test_model.py --model MobileNetV2 --no-normalize --output $output_dir --model_path $modelpath
echo "Training and testing complete."
echo " "

checkpoint="/cmlscratch/avi1/my_model_chks/mobilenet_normalized"
modelpath="${checkpoint}/MobileNetV2_seed_${seed}_normalize=True_augment=False_optimizer=SGD_epoch=199.t7"
output_dir="mobilenet_chkpoints"

echo " "
echo "mkdir -p ${output_dir}"
mkdir -p $output_dir
echo " "
echo "Training MobileNetV2."
python train_model.py --seed ${seed} --model MobileNetV2 --epochs 200 --lr 0.1 --lr_factor 0.1 --lr_schedule 100 150 --optimizer SGD --checkpoint $checkpoint --save_net --output $output_dir --normalize
python test_model.py --model MobileNetV2 --normalize --output $output_dir --model_path $modelpath
echo "Training and testing complete."
echo " "

checkpoint="/cmlscratch/avi1/my_model_chks/mobilenet_augment"
modelpath="${checkpoint}/MobileNetV2_seed_${seed}_normalize=True_augment=True_optimizer=SGD_epoch=199.t7"
output_dir="mobilenet_chkpoints"

echo " "
echo "mkdir -p ${output_dir}"
mkdir -p $output_dir
echo " "
echo "Training MobileNetV2."
python train_model.py --seed ${seed} --model MobileNetV2 --epochs 200 --lr 0.1 --lr_factor 0.1 --lr_schedule 100 150 --optimizer SGD --checkpoint $checkpoint --save_net --output $output_dir --normalize --train_augment
python test_model.py --model MobileNetV2 --normalize --train_augment --output $output_dir --model_path $modelpath
echo "Training and testing complete."
echo " "

#checkpoint="/cmlscratch/avi1/my_model_chks/resnet18_notnormalized"
#modelpath="${checkpoint}/resnet18_seed_${seed}_normalize=False_augment=False_optimizer=SGD_epoch=199.t7"
#output_dir="resnet18_chkpoints"
#
#echo " "
#echo "mkdir -p ${output_dir}"
#mkdir -p $output_dir
#echo " "
#echo "Training ResNet18."
#python train_model.py --seed ${seed} --model resnet18 --epochs 200 --lr 0.1 --lr_factor 0.1 --lr_schedule 100 150 --optimizer SGD --checkpoint $checkpoint --save_net --output $output_dir --no-normalize
#python test_model.py --model resnet18 --no-normalize --output $output_dir --model_path $modelpath
#echo "Training and testing complete."
#echo " "
#
#checkpoint="/cmlscratch/avi1/my_model_chks/resnet18_normalized"
#modelpath="${checkpoint}/resnet18_seed_${seed}_normalize=True_augment=False_optimizer=SGD_epoch=199.t7"
#output_dir="resnet18_chkpoints"
#
#echo " "
#echo "mkdir -p ${output_dir}"
#mkdir -p $output_dir
#echo " "
#echo "Training ResNet18."
#python train_model.py --seed ${seed} --model resnet18 --epochs 200 --lr 0.1 --lr_factor 0.1 --lr_schedule 100 150 --optimizer SGD --checkpoint $checkpoint --save_net --output $output_dir --normalize
#python test_model.py --model resnet18 --normalize --output $output_dir --model_path $modelpath
#echo "Training and testing complete."
#echo " "
#
#checkpoint="/cmlscratch/avi1/my_model_chks/resnet18_augment"
#modelpath="${checkpoint}/resnet18_seed_${seed}_normalize=True_augment=True_optimizer=SGD_epoch=199.t7"
#output_dir="resnet18_chkpoints"
#
#echo " "
#echo "mkdir -p ${output_dir}"
#mkdir -p $output_dir
#echo " "
#echo "Training ResNet18."
#python train_model.py --seed ${seed} --model resnet18 --epochs 200 --lr 0.1 --lr_factor 0.1 --lr_schedule 100 150 --optimizer SGD --checkpoint $checkpoint --save_net --output $output_dir --normalize --train_augment
#python test_model.py --model resnet18 --normalize --train_augment --output $output_dir --model_path $modelpath
#echo "Training and testing complete."
#echo " "
