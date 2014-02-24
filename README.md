fusegen
=======

> This project creates dynamic quickstarts for JBoss Fuse and JBoss A-MQ.

Pre-Requisites
--------------

Ruby and RubyGems installed on your local machine.


Try it out
-----------


    >gem install fusegen

Then for a list of options

    >fusegen help


Configure and Query
-------------------


Add a repo to your configuration

    >fusegen repo add https://raw.github.com/dstanley/fusegen-templates/master/

Query the available quickstarts

    >fusegen qs list



Examples
========

Generate a camel project using defaults

    >fusegen new camel-base

Generate a camel project using 2.10.0.redhat-60060

    >fusegen new -f 60060 -g com.mycompany.camel camel-base

Generate a spring based cxf wsdl-first project

    >fusegen new -g com.mycompany.camel cxf-wsdl-first

Generate a basic jms consumer

    >fusegen new amq-consumer

Generate a multi-threaded jms producer

    >fusegen new amq-producer


Latest Code
===========

To install from the latest source
    
    >git clone https://github.com/dstanley/fusegen.git
    >rake package
    >gem install ./pkg/fusegen-0.0.1.gem


