#!/bin/bash

# Lines that begin with #SBATCH specify commands to be used by SLURM for scheduling
#SBATCH --job-name=frogs_arr                            # sets the job name if not set from environment
#SBATCH --array=1-20                                # Submit 8 array jobs, throttling to 4 at a time
#SBATCH --output cmllogs/%x_%A_%a.log                   # redirect STDOUT to; %j is the jobid, _%A_%a is array task id
#SBATCH --error cmllogs/%x_%A_%a.log                    # redirect STDERR to; %j is the jobid,_%A_%a is array task id
#SBATCH --account=scavenger                             # set QOS, this will determine what resources can be requested
#SBATCH --qos=scavenger                                 # set QOS, this will determine what resources can be requested
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=1
#SBATCH --partition=scavenger
#SBATCH --mem 16gb                                      # memory required by job; MB will be assumed
#SBATCH --mail-user avi1@umd.edu
#SBATCH --mail-type=END,TIME_LIMIT,FAIL,ARRAY_TASKS
#SBATCH --time=08:00:00                                 # how long will the job will take to complete; format=hh:mm:ss

echo "Testing PoisonFrogs attack."

## if on 2207d
#SLURM_ARRAY_TASK_ID=0

echo "mkdir -p logs/frogs"
mkdir -p logs/frogs

PP="/cmlscratch/avi1/poisons/frogsout_${SLURM_ARRAY_TASK_ID}"
#PP="frogsout_${SLURM_ARRAY_TASK_ID}"
MP="/cmlscratch/avi1/my_model_chks/resnet18_seed_1000_epoch=199.t7"
TAR=2
BAS=5
OP=0.3

python craft_poisons_frogs.py --num_poisons 200 --watermark_coeff $OP --poisons_path $PP --model_path $MP --target_class $TAR --poisoned_label $BAS --target_img_idx ${SLURM_ARRAY_TASK_ID} --crafting_iters 12000 --model resnet18 --output logs/frogs/
python poison_test.py --poisons_path $PP --model resnet18 --optimizer SGD --lr 0.001 --model_path $MP --epochs 10 --end2end --val_period 10 --output logs/frogs_e2e/ --poisoned_label $BAS
python poison_test.py --poisons_path $PP --model resnet18 --optimizer SGD --lr 0.001 --model_path $MP --epochs 10 --val_period 10 --output logs/frogs_trans/ --poisoned_label $BAS

python poison_test.py --poisons_path $PP --model resnet18 --optimizer SGD --lr 0.001 --model_path /cmlscratch/avi1/my_model_chks/resnet18_seed_1234_epoch=199.t7 --epochs 10 --end2end --val_period 10 --output logs/frogs_e2e/ --poisoned_label $BAS
python poison_test.py --poisons_path $PP --model resnet18 --optimizer SGD --lr 0.001 --model_path /cmlscratch/avi1/my_model_chks/resnet18_seed_1234_epoch=199.t7 --epochs 10 --val_period 10 --output logs/frogs_trans/ --poisoned_label $BAS

python poison_test.py --poisons_path $PP --model resnet34 --optimizer SGD --lr 0.001 --model_path /cmlscratch/avi1/my_model_chks/resnet34_seed_1000_epoch=199.t7 --epochs 10 --end2end --val_period 10 --output logs/frogs_e2e/ --poisoned_label $BAS
python poison_test.py --poisons_path $PP --model resnet34 --optimizer SGD --lr 0.001 --model_path /cmlscratch/avi1/my_model_chks/resnet34_seed_1000_epoch=199.t7 --epochs 10 --val_period 10 --output logs/frogs_trans/ --poisoned_label $BAS

echo "Done testing poison frogs."
