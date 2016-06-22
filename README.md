# Scalable-and-Available-Website

Built a distributed, scalable and fault-tolerant version of the website.The site consists of a set of Application Servers running Apache Tomcat in AWS EC2 instances. The servers run Java Servlet and JSP code implementing the site, together with additional Java code implementing a distributed, fault-tolerant, in-memory session state database similar to the SSM system. The code also registered and shares group membership in an AWS SimpleDB database.
The code mainly consists of:
1.Servlets/JSPs for processing client requests.
2.A distributed session state database analogous to the SSM system: each node will have a local in-memory session data table exposed through a Remote Procedure Call (RPC) server interface.
3.A “bootstrapping” protocol in which newly created server instances register themselves in a shared SimpleDB database to form a cooperating group.
4.A “reboot” protocol in which a crashed instance can be rebooted and rejoins the group, having lost its volatile state.
