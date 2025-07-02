docker build -t ai-dev-env:latest .
docker save -o ai-dev-env.tar ai-dev-env:latest
sudo apptainer build ai-dev-env.sif ai-dev-env.def
rm ai-dev-env.tar