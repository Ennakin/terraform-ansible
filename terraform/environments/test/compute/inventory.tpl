[test]
%{ for index, ip in vm_ips ~}
${vm_hostnames[index]} ansible_host=${ip}
%{ endfor ~}