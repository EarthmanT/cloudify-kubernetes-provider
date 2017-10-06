ctx logger info "Add kubernetes repository"

VM_VERSION=`grep -w '^NAME=' /etc/os-release`

if [[ "$VM_VERSION" == 'NAME="CentOS Linux"' ]]; then
	sudo tee /etc/yum.repos.d/kubernetes.repo <<-'EOF'
	[kubernetes]
	name=Kubernetes
	baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
	enabled=1
	gpgcheck=1
	repo_gpgcheck=1
	gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
	        https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
	EOF

	sudo setenforce 0

	ctx logger info "Install kubernetes"

	sudo yum install -y kubelet-1.7.5-0.x86_64 kubeadm-1.7.5-0
elif [[ "$VM_VERSION" == 'NAME="Ubuntu"' ]]; then
	apt-get update && apt-get install -y apt-transport-https curl
	curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

	sudo tee /etc/apt/sources.list.d/kubernetes.list <<-'EOF'
	deb http://apt.kubernetes.io/ kubernetes-xenial main
	EOF

	sudo apt-get update
	sudo apt-get install -y kubelet kubeadm
else
	ctx logger info "Unknow OS"
fi

sudo sed -i 's|cgroup-driver=systemd|cgroup-driver=cgroupfs --v 6|g' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

ctx logger info "Reload kubernetes"

sudo systemctl daemon-reload
sudo systemctl enable kubelet && sudo systemctl start kubelet
