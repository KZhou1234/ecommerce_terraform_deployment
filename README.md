# Kura Labs Cohort 5- Deployment Workload 5


---


## PURPOSE

In this project, we deployed the e-commerce application to AWS infrastructure provisioned with Terraform, automating the process using Jenkins. This setup provided a comprehensive view of Infrastructure as Code (IaC) in action, including provisioning the infrastructure by configuring the VPC, subnets, load balancer, gateways, and instances.

## SYSTEM DESIGN DIAGRAM


## STEPS

### 1. What is the tech stack? Run the application
The above steps were create instances and run the application manually, performed to better understand how to run a full-stack application that uses React for the frontend and Django for the backend. The frontend has port 3000 open to run React and port 22 open for SSH. This way, the client can access the webpage through the public IP address of the frontend server, and engineers can connect to the frontend server to access its resources.


### 2. Create the Infrastructure Using Terraform
The custom VPC will have two availability zones (AZs) to improve resilience. In order to direct traffic to these two AZs, a load balancer should also be created. The load balancer has its own security group to allow HTTP traffic on port 80 to access the resources. The targets of the load balancer are the frontend servers in the two different AZs.

For each availability zone (AZ), there will be two subnets: public subnets for the frontend servers in the presentation layer and private subnets for the backend servers that run the actual application and maintain the database.

Each subnet has its own route table associated with it to set rules for directing inbound and outbound traffic. The public subnets need to attach the public route table to allow traffic from the internet gateway to access the resources and permit all outbound traffic. However, to protect the source code and the data, the private subnet is restricted in terms of inbound traffic. To communicate with the internet, outbound traffic from the private subnet will be sent to a NAT gateway, which is located in the public subnet in the same AZ as the private subnet.

### 3. Avoid Leaking Credentials on Remote Repository
Add sensitive values to the .gitignore file and appropriately set the server key in Jenkins to ensure that Jenkins can access the credentials and automate the process securely.

## ISSUES/TROUBLESHOOTING  

1. Python Version Drift
The application requires Python 3.9, but the virtual machine has Python 3.12, which causes issues when creating the virtual environment. After researching how to install an older version, I discovered that deadsnakes is the repository to use for installing older versions of Python.

  ```sudo add-apt-repository -y ppa:deadsnakes/ppa```  

2. Permission Denied Issue
I have encountered different permission denied issues during the process. One occurred while running npm install to install packages, and another happened when I needed to load the data. For both issues, my final solution was to run chown to make the Ubuntu user the owner of the files.

3. Load balancer setting up  
Right now my deployment still have issues on load balancing. The webpage can be accessed through the frontend pulic IP address, but in order to better direct coming traffic, load balancer is necessary for this work load especially we have two AZs. The potential solution can be the React configuration. I still need to look into that.



## OPTIMIZATION  
1. This workload provides us with two ways to create the infrastructure and deploy the application: automatically or manually. I have automated the provisioning part, but I still need to access the server manually to add the private IP address for the backend settings and for the data migration. This process can be further optimized and executed fully automatically.

2. Monitoring Optimization
The workload should include a monitoring server in the default VPC. However, I encountered some issues with creating the VPC peering in my Terraform configuration. This will be improved later.
  


## Business Intelligence

The database for this application is not empty.  There are many tables but the following are the ones to focus on: "auth_user", "product", "account_billing_address", "account_stripemodel", and "account_ordermodel"

For each of the following questions (besides #1), you will need to perform SQL queries on the RDS database.  There are multiple methods. here are 2:

a) From the command line, install postgresql so that you can use the psql command to connect to the db with `psql -h <RDS-endpoint> -U <username> -d <database>`. Then run SQL queries like normal from the command line. OR:

b) Use python library `psycopg2` (pip install psycopg2-binary) and connect to the RDS database with the following:

```
import psycopg2

# Database connection details
host = "<your-host>"
port = "5432"  # Default PostgreSQL port
database = "<your-database>"
user = "<your-username>"
password = "<your-password>"

# Establish the connection
conn = psycopg2.connect(
    host=host,
    database=database,
    user=user,
    password=password
)

# Create a cursor object
cur = conn.cursor()
```

you can then execute the query with:

```
cur.execute("SELECT * FROM my_table;")

# Fetch the result of the query
rows = cur.fetchall()
```

How you choose to run these queries is up to you.  You can run them in the terminal, a python script, a jupyter notebook, etc.  

Questions: 

1. Create a diagram of the schema and relationship between the tables (keys). (Use draw.io for this question)
Following are the tables. Each table has their primary key found by using command `\d <name of the table>`

2. How many rows of data are there in these tables?  What is the SQL query you would use to find out how many users, products, and orders there are?
The rows of data is shown in the figure above.
To query the number of rows of a table, we can use SQL, for example `SELECT COUNT(*) FROM auth_user;
`

3. Which states ordered the most products? Least products? Provide the top 5 and bottom 5 states.

4. Of all of the orders placed, which product was the most sold? Please prodide the top 3.

Provide the SQL query used to gather this information as well as the answer.

## CONCLUSION

This is a comprehensive workload that allows us to gain hands-on experience in creating infrastructure using Terraform. By utilizing modules, the setup can be better organized and significantly improve the reusability of resources. I've gained a deep understanding of the resources we've created in this workload, such as route tables, subnets, and VPCs, as well as the relationships between them. By using Jenkins to add user data to the instance, the processes of "init," "plan," "apply," and even "destroy" can be automated.

