import pickle
import numpy as np
import sys
import glob
import json
import cv2
import os
import argparse
np.random.seed(0)

def read_cifar(files, output_path, split):

    for file in files:
        with open(file, 'rb') as fo:
            dict_ = pickle.load(fo, encoding='latin1')
            index = np.array([i for i in range(dict_['data'].shape[0])])
            index = np.random.choice(index, int(0.75*(len(index))), replace=False)
            if not split == 'train':
                output_path = os.path.join(output_path, split)
            else:
                output_path_train = os.path.join(output_path, 'train')
                output_path_val = os.path.join(output_path, 'val')

            for i in range(dict_['data'].shape[0]):
                image = dict_['data'][i]
                # image = np.reshape(image, (3,32,32))
                red = dict_['data'][i][0:1024]
                green = dict_['data'][i][1024:2048]
                blue = dict_['data'][i][2048:3072]
                red = np.reshape(red, (32,32))
                green = np.reshape(green, (32,32))
                blue = np.reshape(blue, (32,32))
                image = np.dstack([red, green, blue])
                image = image.astype(np.uint8)

                if split == 'train':
                    if i in index:
                        path = os.path.join(os.path.join(output_path_train, \
                            str(dict_['labels'][i])), dict_['filenames'][i])
                        
                    else:
                        path = os.path.join(os.path.join(output_path_val, \
                            str(dict_['labels'][i])), dict_['filenames'][i])
                        
                
                else:
                    path = os.path.join(os.path.join(output_path, \
                            str(dict_['labels'][i])), dict_['filenames'][i])
                
                cv2.imwrite(path, image)    

if __name__ == '__main__':

    parser = argparse.ArgumentParser()
    parser.add_argument('--data', default='/cmlscratch/arjgpt27/cifar-10-batches-py/', help='Path of the dataset')
    parser.add_argument('--output_dir', default='/cmlscratch/arjgpt27/cifar', help='Path of the output directory')
    parser.add_argument('--split', default='train', help='Split train or test')
    FLAGS = parser.parse_args()
    filePath = FLAGS.data
    output_path = FLAGS.output_dir
    output_path_ = FLAGS.output_dir

    if not FLAGS.split=='train':
        output_path = os.path.join(output_path, 'test')

        for i in range(10):
            if not os.path.exists(os.path.join(output_path, str(i))):
                os.makedirs(os.path.join(output_path,str(i)))
    else:
        output_path_train = os.path.join(output_path, 'train')

        for i in range(10):
            if not os.path.exists(os.path.join(output_path_train, str(i))):
                os.makedirs(os.path.join(output_path_train,str(i)))

        output_path_val = os.path.join(output_path, 'val')

        for i in range(10):
            if not os.path.exists(os.path.join(output_path_val, str(i))):
                os.makedirs(os.path.join(output_path_val,str(i)))



    if FLAGS.split == 'train':
        files = glob.glob(filePath + 'data_batch_*', recursive=False)
    else:
        files = glob.glob(filePath + 'test_*', recursive=False)

    read_cifar(files, output_path_, FLAGS.split)
