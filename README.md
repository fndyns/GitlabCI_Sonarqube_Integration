# GitlabCI_Sonarqube_Integration
GitlabCI_Sonarqube_Integration

Sonarqube is a server client architecture. We need to deploy the first in order to enable things to be shipped
We need token (endpoint of the sonar qube)
Sonarqube un gitlabda ki tüm repoları görebilmesi için Sonarqube da her bir proje başına sırayla token oluşturuyoruz. Yani Sonarda "create project" diyerek ve oradaki adımları sırayla takip ederek herbir proje için Gitlab Pipeline ını Sonarqube e bağlamış oluyoruz. 



# CAA process

CAA : Certificate Authorization Authority. When we add CAA record for any domain, and we have to give the value, we gven the value amazon.com and amazonaws.com sort of. It means this domain banct-app.com comain always  require SSL from Amazon. Always ask SSL from Amazon. So we added this policy, now we are trying to add certificate  to our EC2 machine from the letsencrypt. As you know, letsencrypt is the free certificate. So CAA is realted to SSL. Basically CAA is Certificate Authorize Authority. We have given the value as Amazon and we give the permissions that this domain is always ask SSL from Amazon according to CAA record. So when we given this record to any domain, it means that our domain is on AWS and we are using the ACM. Then we are using the CAA. If we are using CAA, it means that we are bound to the domain always use the SSL from the ACM. Now we have removed the CAA. It means that we are give to domain it can acquire any SSL service from any other third party. So what I did is I did removed CAA policy for main domain and subdomain. So when I deleted, after that my certificate has been created successfully (via any certbot command) over the machine using the certbot.



 # Nginx was failing to restart because of non existency of fullchain.pem hatası çözümü ;
 
 Certbot komutu düzgün çalışmadığından dolayı pem dosyası oluşamıyor. 
 
 ** UFW should be enabled for all linux machines. Whenever we use certbot, ufw firewall must be enabled.
 
  >sudo ufw status
  >sudo ufw enabled
  >sudo certbot --nginx -d sq.banct-app.com : When we run this command. It failed as "Some challenges have failed". After checking for a while, we realise that the CAA records added to AWS for the main domain banct-app.com and for subdomains *banct-app.com  on Route 53 on AWS were preventing to issuancae the certificate for third party letsencrypt. So we needed to remove CAA records on AWS Route 53. After removing them, we tried to rerun the certbot command. This commands creating everything automatically. I havent added any pem file manually. It is creating everything. Now when certbot command run successfully, I run the renewal command.
 
 >sudo certbot renew --dry-run
 
 I want to add a cronjob renew dry run then will check . That will set the cronjob for the renewal. Because this certificate all will expire every three months and this cronjob will automatically renewal. So we dont need to renew the certificate manually. It will be done by Cronjob automatically every 3 months when we run "sudo certbot renew --dry-run"
 
 ** So we dont need CAA record anymore in our domain. It will not make any rpoblem. CAA record will not make any problem is we not keep any CAA record for this domain. If we keep CAA record, it might be problem. Because we can not afford CAA record from AWS. We know that we are using different SSL in our domain at different. Then fullchain.pem files and all files created automatically.
 
 ** And one more thing is that this file "sq.banct-app.com" is serving your server. (/etc/nginx/sites-enabled/sq.banct-app.com)
 nano sq.banct-app.com
 
 If we look at the configs in this file, this file are the configurations added from Certbot. Afzal hasnt added these configs. He just commented out ssl-certificate and ssl-certificate-keylines. And then uncommented the proxy and the location for the sonarqube and listener and these are the certificates as you can see managed by certbot. For port 80, it permanently redirecting to https.
 
 
 NOT !! :  En başta https sertifika olmadığı için Afzal sq.banct-app.com dosyasında port olarak 443 yerine 80 yazdı ve nginx i restart etti. For the port 80, it permanently redirected to https as you can see below.
 
 Listener need certificate to listen. And we hadnt any certificate at the beginning. Therefore in /etc/nginx/sites-enabled/sq.banct-app.com, I converted port 443 to 80. So we changed our listener to port 80 without SSL at the beginning before we start creating certificates. Because if no certificate, at least our app could listen port 80. Then my nginx it was working. And then I location proxy enabled, the sonarqube was working. And then I have installed nginx certificate after deleted the CAA from authenticity.
 
 
 *** HTTP should be allowed in Security Group of Sonar EC2. Because it is a listener. So whenever someone type HTTP, it will automatically works and it will redirect to the HTTPs. If we remove the listen port 80 from SG, if someone is trying to load HTTP without HTTPs, it will be there and it will not work redirecting, So they will fill like an error. Thw web page will fail to open with HTTP if we do that. So therefore HTTP should be allowed in Security Group of Sonar EC2. So it is best practice to keep HTTP allow in SG
 
 
for UFW,

Basically your certbot need Firewall. Whenever you install the certbot, it needs the Firewall should be there. So we can manage our pots. We can manage our allow traffic. So we can manage our ports. We can manage our allow traffic. It is a one more later for the security. So we need to allow firewall for Linux. So if you allow from security group, and you forgot to remove Then the operating system will not allow. Because we have own allowed firewall.

*** If you allow any port in Security Group, you have to allow into the Firewall as well. It is not only for Certbot. So Firewall should be enabled as best practice for Linux machines.

Allowing any port on UFW on Linux machines, we dont need to do any restart process or anyhing.



** CAA is Certificate Authorited Authority. When we add CAA record  for any domain, we are authorizing that party for the SSL. When we remove CAA record for *.banct-app.com and for banct-app.com, SSL successfully installed by Letscencrypt and after that, we have created certificated via certbot.


# Gitlab CI - Sonar Integrasyonu İçin Sırasıyla Yapılanlar ;

1) Once Sonarqube Instance ı ayağa kaldırıldı. Sonar EC2 Security Groups içerisinden hem HTTP hem HTTPs trafiğine izin verdik. Amacımız sonar web sitesine HTTP ile gidildiğinde HTTPs e yönlendirmesi (nginx configde http traffik için https e kalıcı yönlendirme yapıldı) ve HTTPs içerisindede bağlantının güvenli olması için EC2 makinası içerisine SSL sertifikası yüklenmesi 

2) Sonra Sonar için https sertifikasını enable etmek için Sonar önüne nginx konumlandırdık. Bunun için önce instance a nginx install ettik. Sonra da buna https i enable edebilmek için SSL sertifikası install ettik. SSL sertifika tanımlama için şu link takip edildi https://www.digitalocean.com/community/tutorials/how-to-secure-nginx-with-let-s-encrypt-on-debian-11

3) 
  >sudo apt install nginx
  >sudo apt-get install python3-certbot-nginx
  >lsof -i:80
  >sudo fuser -k 80/tcp
  >sudo rm /etc/nginx/sites-enabled/default (not sure about this command)
  >sudo service nginx restart
  >sudo systemctl daemon-reload
  >sudo apt update
  >sudo apt upgrade
  >sudo systemctl list-unit-files | grep apac
  >cd /var/log/nginx/
  >cat error.log
  >sudo systemctl disable nginx
  >cd /var/log/letsencrypt
  >cat letsencrypt.log 
  >sudo service nginx status
  >cd /etc/nginx/sites-available/
  
Bu directory de ls dediğimizde default dosyası sanırım silinmiş olmalı ve hangi domain üzerinde çalışıyorsak o domain isminde bir dosya olmalı. Şuanda bizde xx adında dosya var ve dosyanın cerbot komutu koşmadan önceki hali bu repodaki  InıtalStatusofNginx file.png dosyasında mevcut.Dosyanın  certbot komutu koştuktan sonraki halide LatestStatusofNginx file.png dosyasında mevcut. Yani biz letsencrpt ile sertifika oluşturduğumuzda sertifikayı oluşturma pemleri oluşturma ve nginx e bunu tanıtma gibi tüm işlemleri letsencrypt yapıyor (fullchain pem gibi tüm dosyalar otomatik oluşturuluyor certbot komutu ile)
>sudo certbot certonly --standalone --debug -d sq.banct-app.com
>sudo certbot certonly --standalone --preferred-challenges http -d sq.banct-app.com

4) Then, you should be seeing that Sonar Web GUI link has Secure Connection by checking website. Then try to login via admin/admin If you can not login via admin/admin, follow the steps below to reset the password


     Firstly, connect to Sonar EC2 Instance on AWS via ssh and connect Sonar DB. To find Sonar DB and password please open the file below and see jdbc username and password ;

     >cd /opt/bitnami/sonarqube/conf
     >cat sonar.properties 

     sonar.jdbc.username=bn_sonarqube
     sonar.jdbc.password=eaee23ce74b4c8bcccca3d444a275b01e8a0906eb5526edcca729e5fb841195c

     >psql -U bn_sonarqube -d bitnami_sonarqube
     >update users set crypted_password='100000$t2h8AtNs1AlCHuLobDjHQTn9XppwTIx88UjqUm4s8RsfTuXQHSd/fpFexAnewwPsO6jGFQUv/24DnO55hY6Xew==', salt='k9x9eN127/3e/hf38iNiKwVfaVk=', hash_method='PBKDF2', reset_password='true', user_local='true', active='true' where login='admin';

     You need to connect sonar db and run the query above. After that you will be seeing output as "UPDATE"

     After that go to Sonarqube GUI and try to login via admin/admin, it will ask you to change the initial password
