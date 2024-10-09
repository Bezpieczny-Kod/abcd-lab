FROM jenkins/jenkins:lts

# Get a Go from official image
COPY --from=golang:1.22.5-alpine3.20 /usr/local/go/ /usr/local/go/

USER root

# Set Go path
ENV PATH $PATH:/usr/local/go/bin
ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 1777 "$GOPATH"

# Install Python3 and setup venv
RUN apt-get update && \
    apt-get install -y python3 python3-pip python3.11-venv && \
    python3 -m venv /opt/venv
ENV PATH /opt/venv/bin:$PATH

# Install Docker
RUN apt-get install -y apt-transport-https \
    ca-certificates \
    curl \
    gnupg2 \
    software-properties-common && \
    install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc && \
    chmod a+r /etc/apt/keyrings/docker.asc && \
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
        tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y docker-ce

# Make sure that /var/run/docker.sock exists; grant permissions
RUN touch /var/run/docker.sock && \
    chown root:docker /var/run/docker.sock && \
    usermod -a -G docker jenkins

# Install TruffleHog / Semgrep / Nuclei / OSV-Scanner
RUN curl -sSfL https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/scripts/install.sh | \
    sh -s -- -b /usr/local/bin && \
    python3 -m pip install semgrep && \
    go install github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest && \
    go install github.com/google/osv-scanner/cmd/osv-scanner@v1

COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
COPY assets/images/abcd_white.png /var/jenkins_home/userContent/layout/abcd_white.png
COPY assets/theme/org.codefirst.SimpleThemeDecorator.xml /var/jenkins_home/org.codefirst.SimpleThemeDecorator.xml
COPY assets/theme/io.jenkins.plugins.logintheme.LoginTheme.xml /var/jenkins_home/io.jenkins.plugins.logintheme.LoginTheme.xml

RUN jenkins-plugin-cli -f /usr/share/jenkins/ref/plugins.txt

WORKDIR /var/jenkins_home/
EXPOSE 8080

CMD ["bash", "-c", "/usr/local/bin/jenkins.sh"]