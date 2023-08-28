import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import fetchConfigurations from '@salesforce/apex/HDT_LC_AmsAdministration.fetchConfigurations';
import isOperationPending from '@salesforce/apex/HDT_LC_AmsAdministration.isOperationPending';
import initializeOperation from '@salesforce/apex/HDT_LC_AmsAdministration.initializeOperation';


const TIME_OUT = 1 * 60 * 1000;

export default class HdtAmsAdministration extends LightningElement {

    @track configurationObj;
    @track btns;
    @track isLoading;
    @track isError;
    @track loadingMessage = 'Caricando configurazioni...';
    @track isOperationPending = false;
    @track operationPending = '';

    connectedCallback(){
        this.isLoading = true;
        fetchConfigurations()
            .then(result => {
                this.configurationObj = JSON.parse(result);
                this.btns = this.buildButtons(this.configurationObj);
                if(this.isOperationPending)
                {
                    this.loadingMessage = this.operationPending + ' ' + 'In Corso...';
                    return;
                }
                else{
                    this.isLoading = false;
                }
            });
        setInterval(() => {
            console.log('### Interval Set with timeout: ' + TIME_OUT);
            if(this.isOperationPending)
            {
                isOperationPending()
                .then(res => {
                    console.log('### Is Operation Pending: ' + res);
                    this.isOperationPending = res;
                    if(!this.isOperationPending)
                    {
                        console.log('### Stopping operations');
                        this.fireToastEvent({title: 'Successo', message: 'Operazione Completata', variant: 'success'});
                        this.operationPending = '';
                        this.isLoading = false;
                    }
                })
            }
        },TIME_OUT);
    }

    handleClick(event){
        event.preventDefault();
        this.isLoading = true;
        const idx = this.configurationObj.findIndex(el => el.id === event.currentTarget.name);
        if(!this.configurationObj[idx].isActive){
            this.fireToastEvent({title: 'Attenzione', message: 'La funzionalità è stata già utilizzata oggi', variant: 'info'});
            this.isLoading = false;
            return;
        }
        this.loadingMessage = this.configurationObj[idx].label + ' ' + 'In Corso...';
        this.isOperationPending = true;
        this.configurationObj[idx].isActive = false;
        this.btns = this.buildButtons(this.configurationObj);
        const method = this.configurationObj[idx].method;
        const className = this.configurationObj[idx].className;
        initializeOperation({method, className})
        .then(result => {
            console.log('### Starting Operation: ' + result);
            this.fireToastEvent({name: 'Successo', message: result, variant: 'success'});
        })
    }

    buildButtons(configObj){
        return configObj.reduce((accumulator, currentValue) => {
            const singleElement = {id: currentValue['id'], 
                label: currentValue['label'],
                className: currentValue['isActive'] ? 'slds-button btn btn-active' : 'slds-button btn btn-disabled',
                iconName: currentValue['isActive'] ? 'action:apex' : 'action:approval',
            }
            if(!this.isOperationPending && currentValue['status'] === 'PENDING')
            {
                this.isOperationPending = true;
                this.operationPending = currentValue['label'];
            }
            return [...accumulator, singleElement];
        }, []);
    }

    fireToastEvent({title, message, variant}){
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

}