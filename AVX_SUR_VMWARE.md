# AVX sur VMWARE 

Selon votre installation VMWARE la fonctionnalité AVX n'est peut être pas installée 

Vous pouvez vérifier sur une machine virtuelle linux si avx est présent avec cette commmande : 

```
cat /proc/cpuinfo|grep avx
```

## Configuration VMWARE 
 Dans Vsphere il faut faire deux actions

- au niveau du cluster il faut activer le VMWare EVC et choisir un mode qui propose l’AVX. Prendre Intel « Sandy Bridge » Generation

- Ensuite sur la VM elle même il faut activer également le mode EVC et choisir ce même mode :


