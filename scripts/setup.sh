#!/bin/bash
#Variables
llm_user="opc"
log_dir="/home/opc/llm-init"
log_file="/home/opc/llm-init/init.log"
gpu_type="a10"
ol_version="ol-8"
llm_svc_path_default="vllm-inference-default"
llm_svc_path_openai="vllm-inference-openai"
python_version="python39"
pip_version="pip3.9"
llm_master_dir="/home/opc/vllm-master"
parallel_gpu_count=4
#Execution
mkdir -p ${log_dir}
touch ${log_file}
echo "[`date`]--- Start of Script ---" |tee -a ${log_file} 2>&1
sudo sh -c "echo '########################################################################' >> /etc/motd"
sudo sh -c "echo 'welcome to host with ${gpu_type} powered by ${ol_version}' >> /etc/motd"
sudo sh -c "echo '########################################################################' >> /etc/motd"
sudo sh -c "echo 'loaded llm : ${model_path}' >> /etc/motd"
sudo sh -c "echo 'service name default: ${llm_svc_path_default}' >> /etc/motd"
sudo sh -c "echo 'service name openai: ${llm_svc_path_openai}' >> /etc/motd"
sudo sh -c "echo '###########################################################################' >> /etc/motd"
echo "[`date`]--- Motd setup completed ---" |tee -a ${log_file}
sudo dnf module install ${python_version} -y >>${log_file} 2>&1
echo "[`date`]--- python ${python_version} installed ---" |tee -a ${log_file}
df -h >> ${log_file} 2>&1
lsblk >> ${log_file} 2>&1
sudo /usr/libexec/oci-growfs -y >> ${log_file} 2>&1
df -h >> ${log_file} 2>&1
lsblk >> ${log_file} 2>&1
echo "[`date`]--- Root fs extended ---" |tee -a ${log_file} 2>&1
sudo dnf install git -y >> ${log_file} 2>&1
echo "[`date`]--- Git CLI installtion completed ---" |tee -a ${log_file} 2>&1
${pip_version} install --user virtualenv >> ${log_file} 2>&1
${pip_version} install --user nvitop >> ${log_file} 2>&1
${pip_version} install --user huggingface_hub >> ${log_file} 2>&1
sudo yum install libnccl -y >> ${log_file} 2>&1
echo "[`date`]--- Python libraries are installed ---" |tee -a ${log_file} 2>&1
mkdir ${llm_master_dir} >> ${log_file} 2>&1
cd ${llm_master_dir} >> ${log_file} 2>&1
virtualenv env >> ${log_file} 2>&1
source env/bin/activate >> ${log_file} 2>&1
pip install vllm >> ${log_file} 2>&1
pip install openai >> ${log_file} 2>&1
echo "[`date`]--- Python Vllm libraries are installed ---" |tee -a ${log_file} 2>&1
sudo firewall-cmd  --zone=public --permanent --add-port ${llm_port_default}/tcp >> ${log_file} 2>&1
sudo firewall-cmd --zone=public --permanent --add-port ${llm_port_openai}/tcp >> ${log_file} 2>&1
sudo firewall-cmd  --zone=public --permanent --add-port 22/tcp >> ${log_file} 2>&1
sudo firewall-cmd --reload >> ${log_file} 2>&1
sudo firewall-cmd --list-all >> ${log_file} 2>&1
echo "[`date`]--- firewall setup completed ---" |tee -a ${log_file} 2>&1
cd ${llm_master_dir} >> ${log_file} 2>&1
echo "source env/bin/activate" >>bash.sh
echo "pip install flash_attn">>bash.sh
echo "export vllm_log_file=vllm_log_file.log" >>bash.sh
echo "python -m vllm.entrypoints.api_server --model ${model_path} --tensor-parallel-size ${parallel_gpu_count} --port ${llm_port_default}>>${vllm_log_file} 2>&1" >>bash.sh
echo "---Startup file for vllm default endpoint service  created ----" |tee -a ${log_file} 2>&1
echo "source env/bin/activate">>bash_openai.sh
echo "pip install flash_attn">>bash_openai.sh
echo "export vllm_log_file=vllm_log_file.log" >>bash_openai.sh
echo "export api_key=${api_key}">>bash_openai.sh
echo "python -m vllm.entrypoints.openai.api_server --model ${model_path} --tensor-parallel-size ${parallel_gpu_count} --port ${llm_port_openai} --api-key "'${api_key}'">>${vllm_log_file} 2>&1" >>bash_openai.sh
echo "[`date`]---Startup file for vllm openai endpoint service  created ----" |tee -a ${log_file} 2>&1
sudo cp /home/opc/openai.svc /etc/systemd/system/vllm-inference-openai.service >> ${log_file} 2>&1
sudo cp /home/opc/default.svc /etc/systemd/system/vllm-inference-default.service >> ${log_file} 2>&1
sudo systemctl daemon-reload >> ${log_file} 2>&1
echo "[`date`]---service setup completed ---"|tee -a ${log_file} 2>&1
sudo systemctl enable vllm-inference-openai.service |tee -a ${log_file} 2>&1
huggingface-cli login --token ${huggingface_access_token} |tee -a ${log_file} 2>&1
sudo systemctl start vllm-inference-openai.service |tee -a ${log_file} 2>&1
sleep 10
sudo systemctl status vllm-inference-openai.service |tee -a ${log_file} 2>&1
echo "[`date`]---End of the script / Log file :{log_file} ---"|tee -a ${log_file} 2>&1





