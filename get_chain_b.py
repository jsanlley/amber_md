#Substrate envelope as defined by Yang et. al, Nature, 582, 2020) and 
# J. Phys. Chem. Lett. 2022, 13, 5776-5786

active_site_a = [41, 145]
oxyanion_a = [145,146,147]
s1_a = [140,141,142,163,166,172]
s1p_a = [24,25,26]
s2_a = [41,49,54,165,187,189]
s3_a = [165,167,168,189,190,191,192]

def get_chain_b(chain_a):
    chain_b = []

    for resnum in chain_a:
        chain_b.append(resnum + 306)

    return chain_b

active_site_b = get_chain_b(active_site_a)
oxyanion_b = get_chain_b(oxyanion_a)
s1_b = get_chain_b(s1_a)
s1p_b = get_chain_b(s1p_a)
s2_b = get_chain_b(s2_a)
s3_b = get_chain_b(s3_a)

a_sites = {"Active site ":active_site_a,"Oxyanion A":oxyanion_a,"S1 A":s1_a,"S1' A":s1p_a,"S2 A":s2_a,"S3 A":s3_a}
b_sites = {"Active site ":active_site_b,"Oxyanion B":oxyanion_b,"S1 B":s1_b,"S1' B":s1p_b,"S2 B":s2_b,"S3 B":s3_b}

print("A sites")
for name, site  in a_sites.items():
    print(name, site)

print("B sites")
for name, site  in b_sites.items():
    print(name, site)

all_residues = []
for sites in a_sites.values():
    for residue in sites:
        all_residues.append(residue)

for sites in b_sites.values():
    for residue in sites:
        all_residues.append(residue)

print(set(all_residues))
