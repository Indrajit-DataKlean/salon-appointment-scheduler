#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only --no-align -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

echo -e "\nWelcome to My Salon, how can I help you?"
MAIN_MENU (){

  if [[ $1 ]]
  then
  echo -e "\n$1"
  fi


DISPLAY_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

echo "$DISPLAY_SERVICES" | while IFS="|" read SERVICE_ID SERVICE_NAME
do
echo "$SERVICE_ID) $SERVICE_NAME"
done

read SERVICE_ID_SELECTED

SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

if [[ -z $SERVICE_NAME ]]
then
MAIN_MENU "I could not find that service. What would you like today?"
else
SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE name = '$SERVICE_NAME'")
CUSTOMER_INFO
fi
}


CUSTOMER_INFO () {

echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

if [[ ! $CUSTOMER_PHONE =~ ^[0-9-]+$ ]]
then
echo -e "\nThis is not a valid phone number."
else

CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
if [[ -z $CUSTOMER_NAME ]]
then
echo -e "\nI don't have a record for that phone number, what's your name?"
read CUSTOMER_NAME
INSERT_CUSTOMER_NAME=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")

CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

fi
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

MAKE_APPOINTMENT
fi
}
MAKE_APPOINTMENT (){
echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
read SERVICE_TIME

INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES( $CUSTOMER_ID, $SERVICE_ID, '$SERVICE_TIME')")

echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."



}

MAIN_MENU