import numpy as np
import matplotlib.pyplot as plt
import glob
import argparse
import os

def make_plot(directory, output_loss, output_acc):

    files = np.sort(glob.glob(directory + '/*/finetune*', recursive=True))
    for file in files:

        title = directory.split('/')[-2].split('_')[-1] + '_' + file.split('/')[-2] + '_'
        content = open(file, 'r')
        lines = content.readlines()
        train_loss = []
        train_acc = []
        test_loss = []
        test_acc = []
        patched_loss = []
        patched_acc = []
        for line in lines:
            # exit(-1)
            if line.find('train Loss:') >= 0:
                start = line.find('train Loss:') + len('train Loss:') + 1
                # 6 is the length of the value
                train_loss.append(float(line[start:start+6]))
                train_acc.append(float(line[len(line)-7 : ]))

            elif line.find('test Loss:') >= 0:
                start = line.find('test Loss:') + len('test Loss:') + 1
                # 6 is the length of the value
                test_loss.append(float(line[start:start+6]))
                test_acc.append(float(line[len(line)-7 : ]))

            elif line.find(' patched Loss:') >= 0:
                start = line.find('patched Loss:') + len('patched Loss:') + 1
                # 6 is the length of the value
                patched_loss.append(float(line[start:start+6]))
                patched_acc.append(float(line[len(line)-7 : ]))
            
            elif line.find('Training complete') >= 0:
                break

        x_lim = np.arange(0, len(train_loss))
        fig = plt.figure()
        plt.plot(x_lim, train_loss, label='train_loss')
        plt.plot(x_lim, test_loss, label='test_loss')
        plt.plot(x_lim, patched_loss, label='patched_loss')
        plt.legend()
        plt.savefig(os.path.join(output_loss, title))

        x_lim = np.arange(0, len(train_acc))
        fig = plt.figure()
        plt.plot(x_lim, train_acc, label='train_acc')
        plt.plot(x_lim, test_acc, label='test_acc')
        plt.plot(x_lim, patched_acc, label='patched_acc')
        plt.legend()
        plt.savefig(os.path.join(output_acc, title))

if __name__ == '__main__':

    Parser = argparse.ArgumentParser()
    Parser.add_argument('--directory', default='/cmlscratch/arjgpt27/hidden_trigger_ImageNet_experiments_mobilenet/logs', 
                    help='path of the directory where eperiments are present')
    Parser.add_argument('--output', default='./plots', help='path of the output directory')
    Flags = Parser.parse_args()

    output_loss = os.path.join(Flags.output, 'Loss')
    output_acc = os.path.join(Flags.output, 'Acc')
    
    if not os.path.exists(output_loss):
    	os.makedirs(output_loss)

    if not os.path.exists(output_acc):
        os.makedirs(output_acc)

    make_plot(Flags.directory, output_loss, output_acc)
