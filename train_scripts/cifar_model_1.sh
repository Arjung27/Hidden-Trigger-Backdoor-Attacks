#python create_imagenet_filelist.py cfg_CIFAR/dataset.cfg &&
CUDA_VISIBLE_DEVICES=0 python generate_poison.py cfg_CIFAR100/singlesource_singletarget_binary_finetune_1/experiment_0011.cfg &&
CUDA_VISIBLE_DEVICES=0 python finetune_and_test.py cfg_CIFAR100/singlesource_singletarget_binary_finetune_1/experiment_0011.cfg &&

CUDA_VISIBLE_DEVICES=0 python generate_poison.py cfg_CIFAR100/singlesource_singletarget_binary_finetune_1/experiment_0012.cfg &&
CUDA_VISIBLE_DEVICES=0 python finetune_and_test.py cfg_CIFAR100/singlesource_singletarget_binary_finetune_1/experiment_0012.cfg &&

CUDA_VISIBLE_DEVICES=0 python generate_poison.py cfg_CIFAR100/singlesource_singletarget_binary_finetune_1/experiment_0013.cfg &&
CUDA_VISIBLE_DEVICES=0 python finetune_and_test.py cfg_CIFAR100/singlesource_singletarget_binary_finetune_1/experiment_0013.cfg &&

CUDA_VISIBLE_DEVICES=0 python generate_poison.py cfg_CIFAR100/singlesource_singletarget_binary_finetune_1/experiment_0014.cfg &&
CUDA_VISIBLE_DEVICES=0 python finetune_and_test.py cfg_CIFAR100/singlesource_singletarget_binary_finetune_1/experiment_0014.cfg &&

CUDA_VISIBLE_DEVICES=0 python generate_poison.py cfg_CIFAR100/singlesource_singletarget_binary_finetune_1/experiment_0015.cfg &&
CUDA_VISIBLE_DEVICES=0 python finetune_and_test.py cfg_CIFAR100/singlesource_singletarget_binary_finetune_1/experiment_0015.cfg &&

CUDA_VISIBLE_DEVICES=0 python generate_poison.py cfg_CIFAR100/singlesource_singletarget_binary_finetune_1/experiment_0016.cfg &&
CUDA_VISIBLE_DEVICES=0 python finetune_and_test.py cfg_CIFAR100/singlesource_singletarget_binary_finetune_1/experiment_0016.cfg &&

CUDA_VISIBLE_DEVICES=0 python generate_poison.py cfg_CIFAR100/singlesource_singletarget_binary_finetune_1/experiment_0017.cfg &&
CUDA_VISIBLE_DEVICES=0 python finetune_and_test.py cfg_CIFAR100/singlesource_singletarget_binary_finetune_1/experiment_0017.cfg &&

CUDA_VISIBLE_DEVICES=0 python generate_poison.py cfg_CIFAR100/singlesource_singletarget_binary_finetune_1/experiment_0018.cfg &&
CUDA_VISIBLE_DEVICES=0 python finetune_and_test.py cfg_CIFAR100/singlesource_singletarget_binary_finetune_1/experiment_0018.cfg &&

CUDA_VISIBLE_DEVICES=0 python generate_poison.py cfg_CIFAR100/singlesource_singletarget_binary_finetune_1/experiment_0019.cfg &&
CUDA_VISIBLE_DEVICES=0 python finetune_and_test.py cfg_CIFAR100/singlesource_singletarget_binary_finetune_1/experiment_0019.cfg &&

CUDA_VISIBLE_DEVICES=0 python generate_poison.py cfg_CIFAR100/singlesource_singletarget_binary_finetune_1/experiment_0020.cfg &&
CUDA_VISIBLE_DEVICES=0 python finetune_and_test.py cfg_CIFAR100/singlesource_singletarget_binary_finetune_1/experiment_0020.cfg
