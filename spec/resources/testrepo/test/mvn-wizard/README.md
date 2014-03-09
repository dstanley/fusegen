A spring based jms queue consumer that uses Springs DefaultMessageListenerContainer.

Compiling the client:

   >mvn install

Running the example:

   >mvn -pConsumer

To change the number of messages to consume etc, edit:

   >./src/main/resources/consumer.properties

The DMLC is configured via:

   >./src/main/resources/consumer.xml


Uses:

- Helpful to test Spring DMLC consumers and drain destinations

