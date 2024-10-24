
system = str(input('pdb system name prefix: '))
com = str(input('x y z r coordinates for center of mass and radius of inclusion sphere: '))

with open('povme_' + system + '.ini', 'w') as file:
        file.write('PDBFileName ' + system + ' \n')
        file.write('GridSpacing 1.0 \n')
        file.write('InclusionSphere ' + com + ' \n')
        file.write('ContiguousPointsCriteria 3 \n')
        file.write('DistanceCutoff 1.09 \n')
        file.write('ConvexHullExclusion none \n')
        file.write('OutputFilenamePrefix ' + system + '_povme/povme_' + ' \n')
        file.write('CompressOutput false \n')
        file.write('NumProcessors 8 \n')
