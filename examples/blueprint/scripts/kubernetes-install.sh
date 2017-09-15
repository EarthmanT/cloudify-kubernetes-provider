ctx logger info "Add kubernetes repository"

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

curl -o lvm https://raw.githubusercontent.com/kubernetes/kubernetes/master/examples/volumes/flexvolume/lvm

PLUGINDIR=/usr/libexec/kubernetes/kubelet-plugins/volume/exec/kubernetes.io~lvm/

mkdir -p $PLUGINDIR
sudo cp lvm $PLUGINDIR

sudo chmod 555 -R $PLUGINDIR
sudo chown root:root -R $PLUGINDIR

ctx logger info "Install kubernetes"

sudo yum install -y kubelet kubeadm
sudo sed -i 's|cgroup-driver=systemd|cgroup-driver=cgroupfs|g' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

ctx logger info "Reload kubernetes"

sudo systemctl daemon-reload
sudo systemctl enable kubelet && sudo systemctl start kubelet
