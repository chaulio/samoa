#! /usr/bin/python

# @file

#
#
# @section DESCRIPTION
#
# Builds sam(oa)^2 with several options.
#

# print the welcome message

import os

#
# set possible variables
#
vars = Variables()

vars.AddVariables(
  PathVariable( 'config', 'build configuration file', None, PathVariable.PathIsFile),
)

env = Environment(variables=vars)

#Set config variables from config file if it exists

if 'config' in env:
  vars = Variables(env['config'])
else:
  vars = Variables()

#Add config variables

vars.AddVariables(
  PathVariable( 'config', 'build configuration file', None, PathVariable.PathIsFile),

  PathVariable( 'build_dir', 'build directory', 'bin/', PathVariable.PathIsDirCreate),

  EnumVariable( 'scenario', 'target scenario', 'darcy',
                allowed_values=('darcy', 'swe', 'generic', 'flash') #, 'heat_eq', 'tests')
              ),

  EnumVariable( 'flux_solver', 'flux solver for FV problems', 'upwind',
                allowed_values=('upwind', 'lf', 'lfbath', 'llf', 'llfbath', 'fwave', 'aug_riemann', 'hlle')
              ),

  ( 'swe_dg_order', 'order of DG method, 0=simple FVM', 0),

  ( 'swe_patch_order', 'order of triangular patches, 1=no_patches', 1),
  
  BoolVariable( 'swe_patch_solver', 'use patch solver? if False, a original non-vectorizable geoclaw implementation will be used', False),
  
  EnumVariable( 'swe_scenario', 'artificial scenario for SWE (only considered when not using ASAGI)', 'radial_dam_break',
                allowed_values=('gaussian_curve',
                                'splashing_pool',
                                'radial_dam_break',
                                'linear_dam_break',
                                'oscillating_lake',
                                'resting_lake',
                                'parabolic_isle',
                                'linear_beach')),

  EnumVariable( 'swe_dg_basis', 'choice of basis polynomes and projection method', 'bernstein_nodal',
                allowed_values=('bernstein_nodal','bernstein_l2')
              ),

  EnumVariable( 'data_refinement', 'input data refinement method', 'integrate',
                allowed_values=('integrate', 'sample')
              ),

  EnumVariable( 'perm_averaging', 'permeability averaging', 'geometric',
                allowed_values=('arithmetic', 'geometric', 'harmonic')
              ),

  EnumVariable( 'mobility', 'mobility term for porous media flow', 'quadratic',
                allowed_values=('linear', 'quadratic', 'brooks-corey')
              ),

  EnumVariable( 'compiler', 'choice of compiler', 'intel',
                allowed_values=('intel', 'gnu')
              ),

  EnumVariable( 'target', 'build target, sets debug flag and optimization level', 'release',
                allowed_values=('debug', 'profile', 'release')
              ),

  BoolVariable( 'assertions', 'enable run-time assertions', False),

  EnumVariable( 'openmp', 'OpenMP mode', 'tasks',
                allowed_values=('noomp', 'notasks', 'tasks', 'adaptive_tasks')
              ),

  EnumVariable( 'mpi', 'MPI support', 'default',
                allowed_values=('nompi', 'default', 'intel', 'mpich2', 'openmpi', 'ibm')
              ),

  BoolVariable( 'standard', 'check for Fortran 2008 standard compatibility', False),

  BoolVariable( 'asagi', 'ASAGI support', True),

  BoolVariable( 'asagi_timing', 'switch on timing of all ASAGI calls', False),

  PathVariable( 'asagi_dir', 'ASAGI directory', '.'),
  
  PathVariable( 'netcdf_dir', 'NetCDF directory: only required when machine=mic, because NetCDF libs need to be compiled with -mmic.', '.'),

  EnumVariable( 'precision', 'floating point precision', 'double',
                allowed_values=('single', 'double', 'quad')
              ),

  EnumVariable( 'vec_report', 'vectorization report', '0',
                allowed_values=('0', '1', '2', '3', '4', '5')
              ),
  EnumVariable( 'vec_phase', 'vectorization phase, multiple phases possible: cg,ipo,loop,offload,openmp,par,pgo,tcollect,vec, all', 'all',
                allowed_values=('cg', 'ipo', 'loop', 'offload', 'openmp', 'par', 'pgo', 'tcollect', 'vec', 'vec,loop', 'all')
              ),

  EnumVariable( 'debug_level', 'debug output level', '1',
                allowed_values=('0', '1', '2', '3', '4', '5', '6', '7')
              ),

  EnumVariable( 'machine', 'target machine', 'host',
                allowed_values=('SSE4.2', 'AVX', 'host', 'mic')
              ),

  BoolVariable( 'library', 'build samoa as a library', False),
)

vars.Add('layers', 'number of vertical layers (0: 2D, >0: 3D)', 0)
vars.Add('exe', 'name of the executable. Per default, some compilation options will be added as suffixes.', 'samoa')

# set environment
env = Environment(ENV = os.environ, variables=vars)

# handle unknown, maybe misspelled variables
unknownVariables = vars.UnknownVariables()

# exit in case of unknown variables
if unknownVariables:
  print "****************************************************"
  print "Error: unknown variable(s):", unknownVariables.keys()
  print "****************************************************"
  Exit(1)

#
# precompiler, compiler and linker flags
#

env['F90PATH'] = ['.', os.path.abspath('src/Samoa/')]
env['LINKFLAGS'] = ''

# Choose compiler
if env['compiler'] == 'intel':
  fc = 'ifort'
  env['F90FLAGS'] = ' -implicitnone -nologo -fpp -allow nofpp-comments -align array64byte'
  env['LINKFLAGS'] += ' -Bdynamic -shared-libgcc -shared-intel'
elif  env['compiler'] == 'gnu':
  fc = 'gfortran'
  env['F90FLAGS'] = '-fimplicit-none -cpp -ffree-line-length-none'
  env.SetDefault(openmp = 'notasks')

# If MPI is active, use the mpif90 wrapper for compilation
if env['mpi'] == 'default':
  env['F90'] = 'MPICH_F90=' + fc + ' OMPI_FC=' + fc + ' I_MPI_F90=' + fc + ' mpif90'
  env['LINK'] = 'MPICH_F90=' + fc + ' OMPI_FC=' + fc + ' I_MPI_F90=' + fc + ' mpif90'
  env['F90FLAGS'] += ' -D_MPI'
elif env['mpi'] == 'ibm':
  env['F90'] = 'MPICH_F90=' + fc + ' OMPI_FC=' + fc + ' I_MPI_F90=' + fc + ' mpif90'
  env['LINK'] = 'MPICH_F90=' + fc + ' OMPI_FC=' + fc + ' I_MPI_F90=' + fc + ' mpif90'
  env['F90FLAGS'] += ' -D_MPI'
elif env['mpi'] == 'mpich2':
  env['F90'] = 'MPICH_F90=' + fc + ' mpif90.mpich2'
  env['LINK'] = 'MPICH_F90=' + fc + ' mpif90.mpich2'
  env['F90FLAGS'] += ' -D_MPI'
elif env['mpi'] == 'openmpi':
  env['F90'] = 'OMPI_FC=' + fc + ' mpif90.openmpi'
  env['LINK'] = 'OMPI_FC=' + fc + ' mpif90.openmpi'
  env['F90FLAGS'] += ' -D_MPI'
elif env['mpi'] == 'intel':
  env['F90'] = 'I_MPI_F90=' + fc + ' mpif90.intel'
  env['LINK'] = 'I_MPI_F90=' + fc + ' mpif90.intel'
  env['F90FLAGS'] += ' -D_MPI'
elif env['mpi'] == 'nompi':
  env['F90'] = fc
  env['LINK'] = fc

# set scenario with preprocessor macros
if env['scenario'] == 'darcy':
  env['F90FLAGS'] += ' -D_DARCY'
  env.SetDefault(asagi = True)
  env.SetDefault(library = False)
elif env['scenario'] == 'swe':
  env['F90FLAGS'] += ' -D_SWE'
  env.SetDefault(asagi = True)
  env.SetDefault(library = False)
elif env['scenario'] == 'generic':
  env['F90FLAGS'] += ' -D_GENERIC'
  env.SetDefault(asagi = False)
  env.SetDefault(library = True)
elif env['scenario'] == 'flash':
  env['F90FLAGS'] += ' -D_FLASH'
  env.SetDefault(asagi = True)
  env.SetDefault(library = False)
elif env['scenario'] == 'heateq':
  env['F90FLAGS'] += ' -D_HEAT_EQ'
  env.SetDefault(asagi = True)
  env.SetDefault(library= False)
elif env['scenario'] == 'tests':
  env['F90FLAGS'] += ' -D_TESTS'
  env.SetDefault(asagi = True)
  env.SetDefault(library = False)

#set compilation flags for OpenMP
if env['openmp'] != 'noomp':
  if env['openmp'] == 'tasks':
    env['F90FLAGS'] += ' -D_OPENMP_TASKS'
  elif env['openmp'] == 'adaptive_tasks':
    env['F90FLAGS'] += ' -D_OPENMP_TASKS -D_OPENMP_TASKS_ADAPTIVITY'

  if env['compiler'] == 'intel':
    env['F90FLAGS'] += ' -openmp'
    env['LINKFLAGS'] += ' -openmp'
  elif env['compiler'] == 'gnu':
    env['F90FLAGS'] += ' -fopenmp'
    env['LINKFLAGS'] += ' -fopenmp'

#set compilation flags and preprocessor macros for the ASAGI library
if env['asagi']:
  env.Append(F90PATH = os.path.abspath(env['asagi_dir'] + '/include'))
  env['F90FLAGS'] += ' -D_ASAGI'
  env['LINKFLAGS'] += ' -Wl,--rpath,' + os.path.abspath(env['asagi_dir']) + '/lib'
  env.Append(LIBPATH = env['asagi_dir'] + '/lib')
  if env['machine'] == 'mic':
    env.Append(LIBS = ['asagi_mic'])
  else:
    env.Append(LIBS = ['asagi', 'numa'])

#Enable or disable timing of ASAGI calls
if env['asagi_timing']:
  env['F90FLAGS'] += ' -D_ASAGI_TIMING'

  if not env['asagi']:
    print "Error: asagi_timing must not be set if asagi is not active"
    Exit(-1)
 
#Choose a flux solver
if env['flux_solver'] == 'upwind':
  env['F90FLAGS'] += ' -D_UPWIND_FLUX'
elif env['flux_solver'] == 'lf':
  env['F90FLAGS'] += ' -D_LF_FLUX'
elif env['flux_solver'] == 'lfbath':
  env['F90FLAGS'] += ' -D_LF_BATH_FLUX'
elif env['flux_solver'] == 'llf':
  env['F90FLAGS'] += ' -D_LLF_FLUX_DG'
  env['F90FLAGS'] += ' -D_FWAVE_FLUX'
elif env['flux_solver'] == 'llfbath':
  env['F90FLAGS'] += ' -D_LLF_BATH_FLUX'
elif env['flux_solver'] == 'fwave':
  env['F90FLAGS'] += ' -D_FWAVE_FLUX'
elif env['flux_solver'] == 'aug_riemann':
  env['F90FLAGS'] += ' -D_AUG_RIEMANN_FLUX'
elif env['flux_solver'] == 'hlle':
  env['F90FLAGS'] += ' -D_HLLE_FLUX'
  
# DG options for SWE scenario
if (int(env['swe_dg_order'])) > 0:
	env['F90FLAGS'] += ' -D_SWE_DG'
        if(env['swe_dg_basis']=='bernstein_nodal'):
          env['F90FLAGS'] += ' -D_SWE_DG_NODAL'
	env['F90FLAGS'] += ' -D_SWE_DG_ORDER=' + env['swe_dg_order']
	env['F90FLAGS'] += ' -D_SWE_DG_DOFS=' + str(int( (int(env['swe_dg_order'])+1)*(int(env['swe_dg_order'])+2)/2))
	if (int(env['swe_patch_order'])) > 1:
		print "WARNING: DG options will override set patch options"
	env['swe_patch_order'] = str(2* int(env['swe_dg_order']) + 1)

if (int(env['swe_patch_order'])) > 1:
  env['F90FLAGS'] += ' -D_SWE_PATCH'
  env['F90FLAGS'] += ' -D_SWE_PATCH_ORDER=' + env['swe_patch_order']
  
if env['swe_patch_solver']:
  if (int(env['swe_patch_order'])) <= 1:
      print "Error: patch solvers are only available when using patches. Set swe_patch_solver=False or swe_patch_order=2 or higher"
      Exit(-1)
  env['F90FLAGS'] += ' -D_SWE_USE_PATCH_SOLVER'
  
#Check if solver is really available (some are not/only available when using patch solvers)
if (int(env['swe_patch_order'])) > 1 and env['swe_patch_solver']:
    if env['flux_solver'] != 'hlle' and env['flux_solver'] != 'fwave' and env['flux_solver'] != 'aug_riemann':
        print "Error: Only hlle, fwave and aug_riemann solvers are available as patch solvers. Try using another solver or setting swe_patch_solver=True"
        Exit(-1)
        
#Select artificial scenario for SWE (if not using ASAGI)
if env['swe_scenario'] == 'radial_dam_break':
  env['F90FLAGS'] += ' -D_SWE_SCENARIO_RADIAL_DAM_BREAK'
elif env['swe_scenario'] == 'linear_dam_break':
  env['F90FLAGS'] += ' -D_SWE_SCENARIO_LINEAR_DAM_BREAK'
elif env['swe_scenario'] == 'oscillating_lake':
  env['F90FLAGS'] += ' -D_SWE_SCENARIO_OSCILLATING_LAKE'
elif env['swe_scenario'] == 'resting_lake':
  env['F90FLAGS'] += ' -D_SWE_SCENARIO_RESTING_LAKE'
elif env['swe_scenario'] == 'gaussian_curve':
  env['F90FLAGS'] += ' -D_SWE_SCENARIO_GAUSSIAN_CURVE'
elif env['swe_scenario'] == 'splashing_pool':
  env['F90FLAGS'] += ' -D_SWE_SCENARIO_SPLASHING_POOL'
elif env['swe_scenario'] == 'parabolic_isle':
  env['F90FLAGS'] += ' -D_SWE_SCENARIO_PARABOLIC_ISLE'
elif env['swe_scenario'] == 'linear_beach':
  env['F90FLAGS'] += ' -D_SWE_SCENARIO_SINGLE_WAVE'




#Choose a mobility term
if env['mobility'] == 'linear':
  env['F90FLAGS'] += ' -D_DARCY_MOB_LINEAR'
if env['mobility'] == 'quadratic':
  env['F90FLAGS'] += ' -D_DARCY_MOB_QUADRATIC'
elif env['mobility'] == 'brooks-corey':
  env['F90FLAGS'] += ' -D_DARCY_MOB_BROOKS_COREY'

#Choose a data refinement method
if env['data_refinement'] == 'integrate':
  env['F90FLAGS'] += ' -D_ADAPT_INTEGRATE'
if env['data_refinement'] == 'sample':
  env['F90FLAGS'] += ' -D_ADAPT_SAMPLE'

#Choose a permeability averaging
if env['perm_averaging'] == 'arithmetic':
  env['F90FLAGS'] += ' -D_PERM_MEAN_ARITHMETIC'
if env['perm_averaging'] == 'geometric':
  env['F90FLAGS'] += ' -D_PERM_MEAN_GEOMETRIC'
elif env['perm_averaging'] == 'harmonic':
  env['F90FLAGS'] += ' -D_PERM_MEAN_HARMONIC'

if env['scenario'] == 'darcy' and not env['flux_solver'] in ['upwind']:
  print "Error: flux solver must be one of ", ['upwind']
  Exit(-1)

if env['scenario'] == 'swe' and env['flux_solver'] in ['upwind']:
  print "Error: flux solver must be one of ", ['lf', 'lfbath', 'llf', 'llfbath', 'fwave', 'aug_riemann']
  Exit(-1)

#Set the number of vertical layers for 2.5D
env['F90FLAGS'] += ' -D_DARCY_LAYERS=' + str(env['layers'])

#Choose a floating point precision
if env['precision'] == 'single':
  env['F90FLAGS'] += ' -D_SINGLE_PRECISION'
elif env['precision'] == 'double':
  env['F90FLAGS'] += ' -D_DOUBLE_PRECISION'
elif env['precision'] == 'quad':
  env['F90FLAGS'] += ' -D_QUAD_PRECISION'

#Choose a compilation target
if env['target'] == 'debug':
  env.SetDefault(debug_level = '3')
  env.SetDefault(assertions = True)

  if env['compiler'] == 'intel':
    env['F90FLAGS'] += ' -g -O0 -D_DEBUG -traceback -check all -debug all -fpe0'
    env['LINKFLAGS'] += ' -g -O0 -traceback -check all -debug all -fpe0'
  elif  env['compiler'] == 'gnu':
    env['F90FLAGS'] += ' -g -O0 -D_DEBUG -fcheck=all -fbacktrace -ffpe-trap=invalid -finit-real=nan'
    env['LINKFLAGS'] += ' -g -O0'
elif env['target'] == 'profile':
  env.SetDefault(debug_level = '1')
  env.SetDefault(assertions = False)

  if env['compiler'] == 'intel':
    env['F90FLAGS'] += ' -g -fast -inline-level=0 -funroll-loops -unroll -trace'
    env['LINKFLAGS'] += ' -g -O3 -ip -ipo -trace'
  elif  env['compiler'] == 'gnu':
    env['F90FLAGS'] += '  -g -O3 -march=native -Wa,-q -malign-double'
    env['LINKFLAGS'] += ' -g -O3'
elif env['target'] == 'release':
  env.SetDefault(debug_level = '1')
  env.SetDefault(assertions = False)

  if env['compiler'] == 'intel':
    env['F90FLAGS'] += ' -fast -fno-alias -align all -inline-level=2 -funroll-loops -unroll'
    env['LINKFLAGS'] += ' -O3 -ip -ipo'
  elif  env['compiler'] == 'gnu':
    env['F90FLAGS'] += ' -Ofast -march=native -Wa,-q -malign-double -funroll-loops -fstrict-aliasing -finline-limit=2048'
    env['LINKFLAGS'] += '  -Ofast -march=native -Wa,-q -malign-double -funroll-loops -fstrict-aliasing -finline-limit=2048'

#In case the Intel compiler is active, add a vectorization report
if env['compiler'] == 'intel':
  env['LINKFLAGS'] += ' -qopt-report' + env['vec_report']
  env['LINKFLAGS'] += ' -qopt-report-phase=' + env['vec_phase']
else:
  env['F90FLAGS'] += ' -ftree-vectorizer-verbose=' + env['vec_report']
  env['LINKFLAGS'] += ' -ftree-vectorizer-verbose=' + env['vec_report']

#Set target machine (currently Intel only. Feel free to add GNU options if needed)
if env['compiler'] == 'intel':
  if env['machine'] == 'host':
    env['F90FLAGS'] += ' -xHost'
  elif env['machine'] == 'mic':
    env['F90'] += ' -mmic'
    env['LINK'] += ' -mmic'
    if env['netcdf_dir'] != '.' and env['asagi']: 
      env['LINKFLAGS'] += ' -L' + env['netcdf_dir']  + '/lib -lnetcdf'
  elif env['machine'] == 'SSE4.2':
    env['F90FLAGS'] += ' -xSSE4.2'
  elif env['machine'] == 'AVX':
    env['F90FLAGS'] += ' -xAVX'
elif env['compiler'] == 'gnu':
  if env['machine'] == 'host':
    env['F90FLAGS'] += ' -march=native -Wa,-q'
  elif env['machine'] == 'SSE4.2':
    env['F90FLAGS'] += ' -msse4.2 -mno-avx'
  elif env['machine'] == 'AVX':
    env['F90FLAGS'] += ' -mavx'

#Enable or disable assertions
if env['assertions']:
  env['F90FLAGS'] += ' -D_ASSERT'

#Enable or disable checks for Fortran 2008 standard compliance
if env['standard']:
  if env['compiler'] == 'intel':
    env['F90FLAGS'] += ' -stand f08'
  elif  env['compiler'] == 'gnu':
    env['F90FLAGS'] += ' -Waliasing -Wampersand -Wconversion -Wsurprising -Wc-binding-type -Wintrinsics-std -Wintrinsic-shadow -Wline-truncation -Wtarget-lifetime -Wreal-q-constant -Wunused '

#Create a shared library instead of an executable
if env['library']:
  env['F90FLAGS'] += ' -fpic'
  env['LINKFLAGS'] += ' -fpic -shared'

#Set debug output level
env['F90FLAGS'] += ' -D_DEBUG_LEVEL=' + env['debug_level']

# generate help text
Help(vars.GenerateHelpText(env))

#
# setup the program name and the build directory
#

if env['exe'] == 'samoa':
    program_name = 'samoa'

    # add descriptors to the executable for any argument that is not default
    program_name += '_' + env['scenario']

    if env['openmp'] != 'tasks':
      program_name += '_' + env['openmp']

    if env['mpi'] != 'default':
      program_name += '_' + env['mpi']

    if not env['asagi']:
      program_name += '_noasagi'

    if env['flux_solver'] != 'aug_riemann':
      program_name += '_' + env['flux_solver']

    if env['precision'] != 'double':
      program_name += '_' + env['precision']

    if env['compiler'] != 'intel':
      program_name += '_' + env['compiler']

    if env['layers'] > 0:
      program_name += '_l' + str(env['layers'])

    if env['target'] != 'release':
      program_name += '_' + env['target']

    if env['machine'] == 'mic':
      program_name += '_mic'
else:
    program_name = env['exe']

if env['library']:
  program_name = 'lib' + program_name + '.so'

# set build directory
build_dir = env['build_dir']
object_dir = build_dir + 'build_'+ program_name + '/'

#set module directory (same as build directory)
if env['compiler'] == 'intel':
  env.Append(F90FLAGS = ' -module ' + object_dir)
elif env['compiler'] == 'gnu':
  env.Append(F90FLAGS = ' -J' + object_dir)

#copy F77 compiler settings from F90 compiler
env['FORTRAN'] = env['F90']
env['FORTRANFLAGS'] = env['F90FLAGS']
env['FORTRANPATH'] = env['F90PATH']

# get a list of object files from SConscript
env.obj_files = []

Export('env')
SConscript('src/SConscript', variant_dir=object_dir, duplicate=0)
Import('env')

# build the program
env.Program(build_dir + program_name, env.obj_files)
