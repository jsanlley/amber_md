import argparse as arg
import numpy as np

# write in ps
def time_to_steps(time: float, unit: str) -> int:
    # 1ns = 1000ps
    # 1ps = 1000fs
    # 2fs = 1 step
    if unit == 'ns':
        return int((time * 1000 * 1000) / 2)
    elif unit == 'ps':
        return int((time * 1000) / 2)
    else:
        raise ValueError('unit not recognized (ps or ns only)')

def steps_to_time(steps: int, unit: str) -> int:
    if unit == 'ns':
        return int((steps / 1000000) * 2)
    elif unit == 'ps':
        return int((steps / 1000) * 2)
    else:
        raise ValueError('unit not recognized (ps or ns only)')

def get_gamd_parameters(simulation_time: float, unit: str):
    # ratio of steps in 200ns GaMD simulation
    nstlim = time_to_steps(simulation_time, unit)
    ntcmdprep = int(nstlim * 0.001) # 0.001 nstlim (0.1%)
    ntcmd = int(nstlim * 0.005) # 0.005 nstlim (0.5%)
    ntebprep = int(nstlim * 0.004) # 0.004 nstlim (0.4%)
    nteb = int(nstlim * 0.25) # 0.25 nstlim (25%)
    nstlim += (ntcmdprep + ntcmd + ntebprep) # add prep steps to total simulation
    gamd = nstlim - ntcmdprep - ntcmd - ntebprep - nteb # 0.75 nstlim (75%)
    return [nstlim, ntcmdprep, ntcmd, ntebprep, nteb, gamd]

if __name__ == '__main__':
    parser = arg.ArgumentParser(description='Calculate GaMD simulation parameters')
    parser.add_argument('-t', '--time', dest='simulation_time', type=float, required=True, help='Simulation time value')
    parser.add_argument('-u', '--unit', type=str, choices=['ns', 'ps'], required=True, help='Time unit (ns or ps)')
    args = parser.parse_args()

    params = get_gamd_parameters(args.simulation_time, args.unit)
    param_names = ['nstlim', 'ntcmdprep', 'ntcmd', 'ntebprep', 'nteb','gamd']

    for name, value in zip(param_names, params):
        print(f'{name} = {int(value)}, {steps_to_time(value,"ps")}ps')
    

