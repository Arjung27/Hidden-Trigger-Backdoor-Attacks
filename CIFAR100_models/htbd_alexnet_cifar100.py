import torch
import torch.nn as nn

# __all__ = ['AlexNet', 'alexnet']

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

class HTBDAlexNetCIFAR100(nn.Module):

  def __init__(self, num_classes=100, poison=False, feature_size=4096):
    super(HTBDAlexNetCIFAR100, self).__init__()
    self.feature_size = feature_size
    self.poison = poison
    self.features = nn.Sequential(
      nn.Conv2d(3, 64, kernel_size=3, stride=2, padding=1),
      nn.ReLU(inplace=True),
      nn.MaxPool2d(kernel_size=3, stride=2),
      nn.Conv2d(64, 192, kernel_size=3, stride=1, padding=1),
      nn.ReLU(inplace=True),
      nn.MaxPool2d(kernel_size=3, stride=2),
      nn.Conv2d(192, 384, kernel_size=3, stride=1, padding=1),
      nn.ReLU(inplace=True),
      nn.Conv2d(384, 256, kernel_size=3, stride=1, padding=1),
      nn.ReLU(inplace=True),
      nn.Conv2d(256, 256, kernel_size=3, stride=1, padding=1),
      nn.ReLU(inplace=True),
      nn.MaxPool2d(kernel_size=3, stride=2),
    )
    self.classifier = nn.Sequential(
      nn.Dropout(),
      nn.Linear(256 * 1 * 1, 4096),
      nn.ReLU(inplace=True),
      nn.Dropout(),
      nn.Linear(4096, feature_size),
      nn.ReLU(inplace=True),
      nn.Linear(feature_size, num_classes),
    )

  def forward(self, x):
    x = self.features(x)
    x = torch.flatten(x, 1)
    for i in range(6):
      x = self.classifier[i](x)
    
    feat = x
    out = self.classifier[6](x)
    
    if self.poison:
      return out, feat
    else:
      return out

def alexnet(pretrained=False, progress=True, poison=False, feature_size=4096, **kwargs):

  model =  HTBDAlexNetCIFAR100(poison=poison, feature_size=feature_size)

  if pretrained:
    print(feature_size)
    model_file_name = '/cmlscratch/arjgpt27/my_model_chks/htbd_alexnet_modified_normalized_bottleneck/htbd_alexnet{}_seed_1001_normalize=True_augment=False_optimizer=adam_epoch=199.t7'.format(feature_size)
    model.load_state_dict(torch.load(model_file_name)['net'])
    print((torch.load(model_file_name)['net']['classifier.1.weight']).shape)
    print((torch.load(model_file_name)['net']['classifier.4.weight']).shape)
    print((torch.load(model_file_name)['net']['classifier.6.weight']).shape)
    
  return model 
