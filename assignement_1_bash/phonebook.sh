#!/bin/bash

#if no parameters passed, show options menu 
if [ "$#" == "0" ]
then 
  echo "The available options are:"
  echo "- Insert new contact name and number, with the option \"-i\""
  echo "- View all saved contacts details, with the option \"-v\""
  echo "- Search by contact name, with the option \"-s\""
  echo "- Delete all records, with \"-e\""
  echo "- Delete only one contact name, with \"-d\" "
  exit 1
fi

#save new contact command
if [ $1 = "-i" ]
then

  if [ $# != 3 ]
  then 
    echo "Invalid parameters!"
    echo "The right command is: bash phonebook.sh -i 'contact_name' 'phone_number'"
    echo "Note: each paramter should be surrounded with single quotes (' ')"
    exit 1
  fi
  #check that name is valid
  temp=`echo $2 | grep -E "^[a-zA-Z0-9\_ -]+$"`
  if [ "$temp" = "$2" ]
  then
    #check that phone number is valid
    temp=`echo $3 | grep -E "^[0-9]+$"`
    if [ "$temp" = "$3" ] 
    then
      #check if this name already exists
      temp=`grep -E "^$2:[0-9]+" ./$0`
      if [[ "$temp" != "" ]]
      then 
	#check if this number has already added to this name before
        temp=`echo $temp | grep -E "$3"`
        if [[ "$temp" != "" ]]
        then
          echo "This contact already exists!"
          exit 0
        fi
        #if this number is new, add it to the contact
        sed -i -E "/^$2:[0-9]+.*/d" ./$0
        echo "$temp,$3" >> ./$0
        echo "Contact updated!"
      else
	#if this contact is new add it
        data="$2:$3"
        echo $data >> ./$0
        echo "New contact added!"
      fi
    else
      echo "Invalid phone number!"
      echo "Valid number should only contain digits from 0 to 9"
      echo "Note: each paramter should be surrounded with single quotes (' ')"
      exit 1
    fi
  else
    echo "Invalid name!"
    echo "Valid name should only contain a-z , A-Z , - , _ and whitespace"
    echo "Note: each paramter should be surrounded with single quotes (' ')"
    exit 1
  fi

#Display all command
elif [ $1 = "-v" ]
then
  if [ $# != 1 ]
  then
    echo "Inavlid parameters!"
    echo "The right command is: bash phonebook.sh -v"
    exit 1
  fi 
  temp=`grep -E "^[a-zA-Z0-9\_ \-]+:[0-9]+" ./$0`
  if [[ $temp != "" ]]
  then
    grep -E "^[a-zA-Z0-9\_ \-]+:[0-9]+" ./$0
  else
    echo "Empty phonebook!"
  fi

#Search by name command
elif [ $1 = "-s" ]
then
  if [ $# != 2 ]
  then
    echo "Invalid parameters!"
    echo "The right command is: bash phonebook.sh -s 'contact_name'"
    echo "Note: each paramter should be surrounded with single quotes (' ')"
    exit 1
  fi
  temp=`grep -E "^[a-zA-Z0-9\_ \-]*$2[a-zA-Z0-9\_ \-]*:[0-9]+" ./$0`
  if [[ "$temp" != "" ]]
  then
    grep -E "^[a-zA-Z0-9\_ \-]*$2[a-zA-Z0-9\_ \-]*:[0-9]+" ./$0
  else
    echo "Contact not found!"
  fi

#delete all command
elif [ $1 = "-e" ]
then
  if [ $# != 1 ]
  then
    echo "Invalid parameters!"
    echo "The right command is: bash phonebook.sh -e"
    exit 1
  fi
  sed -i -E "/^[a-zA-Z0-9\_ \-]+:[0-9]+/d" ./$0
  echo "All contacts have been deleted!"

#delete by name command
elif [ $1 = "-d" ]
then
  if [ $# != 2 ]
  then 
    echo "Invalid  parameters!"
    echo "The right command is: bash phonebook.sh -d 'contact_name'"
    echo "Note: each paramter should be surrounded with single quotes (' ')"
    exit 1
  fi 
  temp=`grep -E "^$2:[0-9]+" ./$0`
  if [[ "$temp" != "" ]] 
  then
    sed -i -E "/^$2:[0-9]+/d" ./$0
    echo "Contact has been deleted!"
  else
    echo "Contact not found!"
  fi

#help command
elif [ $1 == "--help" ] 
then
  echo "The available options are:"
  echo "- Insert new contact name and number, with the option \"-i\""
  echo "- View all saved contacts details, with the option \"-v\""
  echo "- Search by contact name, with the option \"-s\""
  echo "- Delete all records, with \"-e\""
  echo "- Delete only one contact name, with \"-d\" "

else
  echo "Inavlid option!"
  echo "Please use the following commands to show available options:"
  echo 'bash phonebook.sh --help'
  echo 'bash phonebook.sh'
fi

exit 0

#########DataBase##########

