""" Extract imu data from rosbags for imu_tk to calibrate.
"""
import os
import argparse
import sys
import numpy as np
import tempfile, shutil
import csv
import rosbag
from sensor_msgs.msg import Imu

parser = argparse.ArgumentParser(description='Extract imu messages for calibration')
parser.add_argument('--bag_file', default='/home/mikkel/data6_imu.bag', help='Input ROS bag.')
parser.add_argument('--imu_topic', default='/imu/data', help='imu topic')
parser.add_argument('--csv', action='store_true')
parser.add_argument('--csv_file', default='/home/mikkel/imu_data.csv', help='Input CSV file.')

args = parser.parse_args()

if __name__ == '__main__':
    bag = rosbag.Bag(args.bag_file, 'r')

    output_dir = tempfile.mkdtemp()

    gyro = []
    accel = []
    if args.csv:
        with open(args.csv_file,  newline='') as csvfile:
            fieldnames = ('timestamp', 'omega_x', 'omega_y', 'omega_z', 'alpha_x', 'alpha_y', 'alpha_z')
            csv_reader = csv.DictReader(csvfile)
            for row in csv.DictReader(csvfile):
                print('timestamp: ', float(row['timestamp'])/1000000000.0)
                if np.linalg.norm([float(row['alpha_x']), float(row['alpha_y']), float(row['alpha_z'])]) > 0:
                    accel.append((float(row['timestamp'])/1000000000.0, float(row['alpha_x']), float(row['alpha_y']), float(row['alpha_z'])))
                if np.linalg.norm([float(row['omega_x']), float(row['omega_y']), float(row['omega_z'])]) > 0:
                    gyro.append((float(row['timestamp'])/1000000000.0, float(row['omega_x']), float(row['omega_y']), float(row['omega_z'])))
        print(len(gyro), "valid gyro measurements.", len(accel), "valid acc measurements")
    else:
        for topic, msg, t in bag.read_messages(topics=[args.imu_topic]):
            if np.linalg.norm([msg.linear_acceleration.x, msg.linear_acceleration.y, msg.linear_acceleration.z]) > 0:
                accel.append((t.to_sec(), msg.linear_acceleration.x, msg.linear_acceleration.y, msg.linear_acceleration.z))
            if np.linalg.norm([msg.angular_velocity.x, msg.angular_velocity.y, msg.angular_velocity.z]) > 0:
                gyro.append((t.to_sec(), msg.angular_velocity.x, msg.angular_velocity.y, msg.angular_velocity.z))
            print('timestamp: ', t.to_sec())

    gyro_path = os.path.join(output_dir, 'gyro_data.txt')
    accel_path = os.path.join(output_dir, 'accel_data.txt')
    np.savetxt(gyro_path, np.asarray(gyro))
    np.savetxt(accel_path, np.asarray(accel))

    os.system('thirdparty/imu_tk/bin/test_imu_calib {} {}'.format(accel_path, gyro_path))

    # remove temp directory
    shutil.rmtree(output_dir)
