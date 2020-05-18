import torch
import torch.nn as nn

class NormalizeByChannelMeanStd(nn.Module):
    def __init__(self, mean, std):
        super(NormalizeByChannelMeanStd, self).__init__()
        if not isinstance(mean, torch.Tensor):
            mean = torch.tensor(mean)
        if not isinstance(std, torch.Tensor):
            std = torch.tensor(std)
        self.register_buffer("mean", mean)
        self.register_buffer("std", std)

    def forward(self, tensor):
        return normalize_fn(tensor, self.mean, self.std)

    def extra_repr(self):
        return 'mean={}, std={}'.format(self.mean, self.std)

def normalize_fn(tensor, mean, std):
    """Differentiable version of torchvision.functional.normalize"""
    # here we assume the color channel is in at dim=1
    mean = mean[None, :, None, None]
    std = std[None, :, None, None]
    return tensor.sub(mean).div(std)

class AlexNet(nn.Module):
    def __init__(self, num_classes=10, poison=False, feature_size=64):
        super(AlexNet, self).__init__()
        self.feature_size = feature_size
        self.conv1 = nn.Conv2d(3, 64, kernel_size=5, stride=1, padding=2)
        self.relu1 = nn.ReLU()
        self.maxpool1 = nn.MaxPool2d(kernel_size=3, padding=1, stride=2)
        self.lrn1 = nn.LocalResponseNorm(9, k=1.0, alpha=0.001, beta=0.75)
        self.conv2 = nn.Conv2d(64, feature_size, kernel_size=5, stride=1, padding=2)
        self.relu2 = nn.ReLU()
        self.lrn2 = nn.LocalResponseNorm(9, k=1.0, alpha=0.001, beta=0.75)
        self.maxpool2 = nn.MaxPool2d(kernel_size=3, padding=1, stride=2)

        self.linear1 = nn.Linear(feature_size*8*8, 384)
        self.relu3 = nn.ReLU()
        self.linear2 = nn.Linear(384, 192)
        self.relu4 = nn.ReLU()
        self.linear = nn.Linear(192, num_classes)
        self.poison = poison

    def forward(self, x):
        feats = self.maxpool2(self.lrn2(self.relu2(self.conv2(self.lrn1(self.maxpool1(self.relu1(self.conv1(x))))))))
        feats_vec = feats.view(feats.size(0), self.feature_size*8*8)
        feat = self.relu4(self.linear2(self.relu3(self.linear1(feats_vec))))
        out = self.linear(feat)
        if self.poison:
        	return out, feat
        else:
        	return out

    def penultimate(self, x):
        feats = self.maxpool2(self.lrn2(self.relu2(self.conv2(self.lrn1(self.maxpool1(self.relu1(self.conv1(x))))))))
        feats_vec = feats.view(feats.size(0), self.feature_size*8*8)
        out = self.relu4(self.linear2(self.relu3(self.linear1(feats_vec))))
        return out

def alexnet(pretrained=False, progress=True, poison=False, feature_size=64, **kwargs):

	model =  AlexNet(poison=poison, feature_size=feature_size)

	if pretrained:
		print(feature_size)
		model_file_name = '/nfshomes/arjgpt27/Experiments/Hidden-Trigger-Backdoor-Attacks_bottleneck/htbd_alexnet_normalized/htbd_alexnet{}_seed_1001_normalize=True_augment=False_optimizer=adam_epoch=199.t7'.format(feature_size)
		model.load_state_dict(torch.load(model_file_name)['net'])
    
	return model 
