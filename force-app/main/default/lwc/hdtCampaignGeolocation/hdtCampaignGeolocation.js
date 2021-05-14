import { LightningElement, track, wire } from 'lwc';
import getContactsByOwnerId from '@salesforce/apex/HDT_LC_GeolocationCommunity.getContactsByOwnerId';
import getContactCoordinates from '@salesforce/apex/HDT_LC_GeolocationCommunity.getContactCoordinates';
import getContactsWithinDistance from '@salesforce/apex/HDT_LC_GeolocationCommunity.getContactsWithinDistance';
import getLeadsWithinDistance from '@salesforce/apex/HDT_LC_GeolocationCommunity.getLeadsWithinDistance';
import { getRecord, deleteRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import { refreshApex } from '@salesforce/apex';

export default class HdtCampaignGeolocation extends LightningElement {
    @track distance = 5;
    @track userId;
    @track contactId = null;
    @track oldContactId = null;
    @track userName;
    @track userMailingLatitude = null;
    @track userMailingLongitude = null;
    @track showListView = false;
    @track showSpinner = false;
    @track dataList = [];
    @track rowOffset = 0;
    @track attempts = 0;
    @track timer;
    @wire(getRecord, {
        recordId: USER_ID,
        fields: [NAME_FIELD]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
            console.log(JSON.stringify(error));
        } else if (data) {
            this.userName = data.fields.Name.value;
            this.userId = data.id;
        }
    }

    @wire(getContactsByOwnerId, { ownerId: '$userId', ownerName: '$userName' })
    getUserContactByOwnerId(result) {
        if (result.data && result.data.length > 0) {
            this.contactId = result.data[0].Id;
            console.log(this.contactId);
        } else {
            console.log(JSON.stringify(result.error));
        }
    };

    getCoordinates() {
        if (this.attempts < 10) {
            getContactCoordinates({ contactId: this.contactId }).then((data) => {
                this.attempts++;
                console.log("ok " + JSON.stringify(data));
                if (data != null) {
                    if (data.hasOwnProperty("MailingLatitude")) {
                        this.userMailingLatitude = data.MailingLatitude;
                        this.userMailingLongitude = data.MailingLongitude;
                        this.getContactsAndLeads();
                    } else {
                        //this.showSpinner = false;
                        console.log("missing coordinates " + this.attempts);
                    }
                } else {
                    this.showSpinner = false;
                    console.log("no data to display");
                }
            }).catch(err => {
                console.log(JSON.stringify(err));
            });
        } else {
            clearInterval(this.timer);
            console.log("timer stopped " + this.attempts);
            this.showSpinner = false;
        }
    }

    columnsList = [
        { label: 'Nome', fieldName: 'firstName' },
        { label: 'Cognome', fieldName: 'lastName' },
        { label: 'Cellulare', fieldName: 'phone', type: 'phone' },
        { label: 'Indirizzo email', fieldName: 'email', type: 'email' },
        { label: 'Indirizzo', fieldName: 'mailingAddress' },
        { label: 'Campagna', fieldName: 'campaignUrl', type: 'url', typeAttributes: { label: { fieldName: 'campaign' } } },
        { label: 'Link', fieldName: 'link', type: 'url', typeAttributes: { label: 'Details' } },
    ];

    submitAddress(event) {
        event.preventDefault();
        this.showListView = false;
        const fields = event.detail.fields;
        //delete existing contact
        if (this.contactId != null) {
            this.oldContactId = this.contactId;
            deleteRecord(this.contactId).then(() => {
                //create new contact
                fields.FirstName = this.userName.split(' ')[0];
                fields.LastName = this.userName.split(' ')[1];
                fields.MailingCountry = 'Italy';
                this.template.querySelector('lightning-record-edit-form').submit(fields);
                this.showSpinner = true;
            }).catch(err => {
                console.log(JSON.stringify(err));
            });
        } else {
            //create new contact
            fields.FirstName = this.userName.split(' ')[0];
            fields.LastName = this.userName.split(' ')[1];
            fields.MailingCountry = 'Italy';
            this.template.querySelector('lightning-record-edit-form').submit(fields);
            this.showSpinner = true;
        }
    }

    getContactsAndLeads() {
        this.dataList = [];
        //get Contacts
        getContactsWithinDistance({
            latitude: this.userMailingLatitude,
            longitude: this.userMailingLongitude,
            distanceKm: this.distance
        }).then(data => {
            data.forEach(obj => {
                this.dataList.push({
                    id: obj.Contact.Id,
                    firstName: obj.Contact.FirstName,
                    lastName: obj.Contact.LastName,
                    phone: obj.Contact.Phone,
                    email: obj.Contact.Email,
                    mailingAddress: `${obj.Contact.MailingAddress.street}, ${obj.Contact.MailingAddress.postalCode}, ${obj.Contact.MailingAddress.city}`,
                    campaign: obj.Campaign.Name,
                    campaignUrl: `/${obj.Campaign.Id}`,
                    link: `/${obj.Contact.Id}`
                });
            });
            //get Leads
            getLeadsWithinDistance({
                latitude: this.userMailingLatitude,
                longitude: this.userMailingLongitude,
                distanceKm: this.distance
            }).then(data => {
                data.forEach(obj => {
                    this.dataList.push({
                        id: obj.Lead.Id,
                        firstName: obj.Lead.FirstName,
                        lastName: obj.Lead.LastName,
                        phone: obj.Lead.Phone,
                        email: obj.Lead.Email,
                        mailingAddress: `${obj.Lead.Address.street}, ${obj.Lead.Address.postalCode}, ${obj.Lead.Address.city}`,
                        campaign: obj.Campaign.Name,
                        campaignUrl: `/${obj.Campaign.Id}`,
                        link: `/${obj.Lead.Id}`
                    });
                });
                this.showListView = true;
                this.showSpinner = false;

                clearInterval(this.timer);
                console.log("timer stopped " + this.attempts);
            }).catch(err => {
                console.log(JSON.stringify(err));
                this.showListView = true;
                this.showSpinner = false;
            });
        }).catch(err => {
            console.log(JSON.stringify(err));
        });
    }

    handleSuccess(event) {
        //get MailingLatitude and MailingLongitude of the submitted contact
        this.contactId = event.detail.id;
        this.attempts = 0;
        this.timer = setInterval(() => {
            this.getCoordinates();
        }, 3000);
    }
}