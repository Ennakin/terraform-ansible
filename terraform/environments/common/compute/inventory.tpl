[reverse-nginx]
%{ for index, ip in vm_ips_reverse ~}
${vm_hostnames_reverse[index]} ansible_host=${ip}
%{ endfor ~}