#!/bin/bash

# Lines that begin with #SBATCH specify commands to be used by SLURM for scheduling
#SBATCH --job-name=256Feat                            # sets the job name if not set from environment
#SBATCH --array=1                                 # Submit 8 array jobs, throttling to 4 at a time
#SBATCH --account=scavenger                           # set QOS, this will determine what resources can be requested
#SBATCH --qos=scavenger                                 # set QOS, this will determine what resources can be requested
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=4
#SBATCH --partition=scavenger
#SBATCH --mem 16gb                                      # memory required by job; MB will be assumed
#SBATCH --mail-user arjung15@umd.edu
#SBATCH --mail-type=END,TIME_LIMIT,FAIL,ARRAY_TASKS
#SBATCH --time=24:00:00                                 # how long will the job will take to complete; format=hh:mm:ss


#python train_model.py --seed 1000 --model resnet18 --epochs 200 --lr 0.1 --lr_factor 0.1 --lr_schedule 100 150 --optimizer SGD --checkpoint /cmlscratch/avi1/my_model_chks --save_net --output my_models_output

#python train_model.py --seed 1000 --model DenseNet121 --epochs 200 --lr 0.1 --lr_factor 0.1 --lr_schedule 100 150 --optimizer SGD --checkpoint /cmlscratch/avi1/my_model_chks --save_net --output my_models_output

# python train_model.py --seed 1000 --model MobileNetV2 --epochs 200 --lr 0.1 --lr_factor 0.1 --lr_schedule 100 150 --optimizer SGD --checkpoint /cmlscratch/avi1/my_model_chks --save_net --output my_models_output

python generate_poison.py cfg_CIFAR/singlesource_singletarget_binary_finetune_2/experiment_0011.cfg &&
python finetune_and_test.py cfg_CIFAR/singlesource_singletarget_binary_finetune_2/experiment_0011.cfg &&

python generate_poison.py cfg_CIFAR/singlesource_singletarget_binary_finetune_2/experiment_0012.cfg &&
python finetune_and_test.py cfg_CIFAR/singlesource_singletarget_binary_finetune_2/experiment_0012.cfg &&

python generate_poison.py cfg_CIFAR/singlesource_singletarget_binary_finetune_2/experiment_0013.cfg &&
python finetune_and_test.py cfg_CIFAR/singlesource_singletarget_binary_finetune_2/experiment_0013.cfg &&

python generate_poison.py cfg_CIFAR/singlesource_singletarget_binary_finetune_2/experiment_0014.cfg &&
python finetune_and_test.py cfg_CIFAR/singlesource_singletarget_binary_finetune_2/experiment_0014.cfg &&

python generate_poison.py cfg_CIFAR/singlesource_singletarget_binary_finetune_2/experiment_0015.cfg &&
python finetune_and_test.py cfg_CIFAR/singlesource_singletarget_binary_finetune_2/experiment_0015.cfg &&

python generate_poison.py cfg_CIFAR/singlesource_singletarget_binary_finetune_2/experiment_0016.cfg &&
python finetune_and_test.py cfg_CIFAR/singlesource_singletarget_binary_finetune_2/experiment_0016.cfg &&

python generate_poison.py cfg_CIFAR/singlesource_singletarget_binary_finetune_2/experiment_0017.cfg &&
python finetune_and_test.py cfg_CIFAR/singlesource_singletarget_binary_finetune_2/experiment_0017.cfg &&

python generate_poison.py cfg_CIFAR/singlesource_singletarget_binary_finetune_2/experiment_0018.cfg &&
python finetune_and_test.py cfg_CIFAR/singlesource_singletarget_binary_finetune_2/experiment_0018.cfg

python generate_poison.py cfg_CIFAR/singlesource_singletarget_binary_finetune_2/experiment_0019.cfg &&
python finetune_and_test.py cfg_CIFAR/singlesource_singletarget_binary_finetune_2/experiment_0019.cfg &&

python generate_poison.py cfg_CIFAR/singlesource_singletarget_binary_finetune_2/experiment_0020.cfg &&
python finetune_and_test.py cfg_CIFAR/singlesource_singletarget_binary_finetune_2/experiment_0020.cfg
