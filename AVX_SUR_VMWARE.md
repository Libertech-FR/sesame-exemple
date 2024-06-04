# AVX sur VMWARE 

Selon votre installation VMWARE la fonctionnalité AVX n'est peut être pas installée 

Vous pouvez vérifier sur une machine virtuelle linux si avx est présent avec cette commmande : 

```
cat /proc/cpuinfo|grep avx
```

## Configuration VMWARE 
 Dans Vsphere il faut faire deux actions

- au niveau du cluster il faut activer le VMWare EVC et choisir un mode qui propose l’AVX. Prendre Intel « Sandy Bridge » Generation

![Image31](https://github.com/Libertech-FR/sesame-exemple/assets/7698629/bb0bda04-ee22-4cc5-9434-92edb02577a7)

- Ensuite sur la VM elle même il faut activer également le mode EVC et choisir ce même mode :

![Image32](https://github.com/Libertech-FR/sesame-exemple/assets/7698629/84fa1ac6-a702-477d-90f5-b1b57d7b1bcf)

