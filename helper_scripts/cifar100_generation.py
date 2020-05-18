import pickle
import numpy as np
import sys
import glob
import json
import cv2
import os
from tqdm import tqdm
from scipy import misc
import argparse
np.random.seed(0)

def unpickle(file):
    with open(file, 'rb') as fo:
        res = pickle.load(fo, encoding='bytes')
    return res

def read_cifar(output_path, data_folder):

    meta = unpickle(os.path.join(data_folder, 'meta'))

    fine_label_names = [t.decode('utf8') for t in meta[b'fine_label_names']]

    train = unpickle(os.path.join(data_folder, 'train'))

    filenames = [t.decode('utf8') for t in train[b'filenames']]
    fine_labels = train[b'fine_labels']
    data = train[b'data']

    images = list()
    for d in data:
        image = np.zeros((32,32,3), dtype=np.uint8)
        image[...,2] = (np.reshape(d[:1024], (32,32))).astype(np.uint8) # Red channel
        image[...,1] = (np.reshape(d[1024:2048], (32,32))).astype(np.uint8) # Green channel
        image[...,0] = (np.reshape(d[2048:], (32,32))).astype(np.uint8) # Blue channel
        images.append(image)

    index = np.int32([i for i in range(len(images))])
    index_ = np.random.choice(index, int(0.75*(len(index))), replace=False)

    for index, image in tqdm(enumerate(images)):
        filename = filenames[index]
        label = fine_labels[index]

        if index in index_:
            img_name = os.path.join(os.path.join(os.path.join(output_path, 'train'), str(label)), filename)
            cv2.imwrite(img_name, image)
        else:
            img_name = os.path.join(os.path.join(os.path.join(output_path, 'val'), str(label)), filename)
            cv2.imwrite(img_name, image)

    test = unpickle(os.path.join(data_folder, 'test'))

    filenames = [t.decode('utf8') for t in test[b'filenames']]
    fine_labels = test[b'fine_labels']
    data = test[b'data']

    images = list()
    for d in data:
        image = np.zeros((32,32,3), dtype=np.uint8)
        image[...,2] = (np.reshape(d[:1024], (32,32))).astype(np.uint8) # Red channel
        image[...,1] = (np.reshape(d[1024:2048], (32,32))).astype(np.uint8) # Green channel
        image[...,0] = (np.reshape(d[2048:], (32,32))).astype(np.uint8) # Blue channel
        images.append(image)


    for index, image in tqdm(enumerate(images)):
        filename = filenames[index]
        label = fine_labels[index]

        img_name = os.path.join(os.path.join(os.path.join(output_path, 'test'), str(label)), filename)
        cv2.imwrite(img_name, image)
        # print(filename, label)
        # label = fine_label_names[label]
        # misc.imsave() 

if __name__ == '__main__':

    parser = argparse.ArgumentParser()
    parser.add_argument('--data', default='/cmlscratch/arjgpt27/cifar-100-python/', help='Path of the dataset')
    parser.add_argument('--output_dir', default='/cmlscratch/arjgpt27/cifar100', help='Path of the output directory')
    # parser.add_argument('--split', default='train', help='Split train or test')
    FLAGS = parser.parse_args()
    filePath = FLAGS.data
    output_path = FLAGS.output_dir
    output_path_ = FLAGS.output_dir

    output_path = os.path.join(output_path, 'test')

    for i in range(100):
        if not os.path.exists(os.path.join(output_path, str(i))):
            os.makedirs(os.path.join(output_path,str(i)))
    output_path_train = os.path.join(output_path, 'train')

    for i in range(100):
        if not os.path.exists(os.path.join(output_path_train, str(i))):
            os.makedirs(os.path.join(output_path_train,str(i)))

    output_path_val = os.path.join(output_path, 'val')

    for i in range(100):
        if not os.path.exists(os.path.join(output_path_val, str(i))):
            os.makedirs(os.path.join(output_path_val,str(i)))


    # if FLAGS.split == 'train':
    #     files = glob.glob(filePath + 'train', recursive=False)
    # else:
    #     files = glob.glob(filePath + 'test', recursive=False)

    read_cifar(output_path_, FLAGS.data)
