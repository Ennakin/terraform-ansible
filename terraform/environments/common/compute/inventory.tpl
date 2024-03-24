[common]
%{ for index, ip in vm_ips ~}
${vm_hostnames[index]} ansible_host=${ip}
%{ endfor ~}

${/**
%{ for index, ip in vm_ips_open_vpn ~}
${vm_hostnames_open_vpn[index]} ansible_host=${ip}
%{ endfor ~}
*/"" }