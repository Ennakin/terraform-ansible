[open-vpn]
%{ for index, ip in vm_ips_open_vpn ~}
${vm_hostnames_open_vpn[index]} ansible_host=${ip}
%{ endfor ~}

${/**
[reverse-nginx]
%{ for index, ip in vm_ips_reverse ~}
${vm_hostnames_reverse[index]} ansible_host=${ip}
%{ endfor ~}
*/"" }