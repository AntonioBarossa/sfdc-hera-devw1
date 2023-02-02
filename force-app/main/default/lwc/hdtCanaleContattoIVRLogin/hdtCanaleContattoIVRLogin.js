import {
    api,
    LightningElement,
    track,
    wire
} from 'lwc';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';

import {
    getRecord,
    getFieldValue
} from 'lightning/uiRecordApi';
import IMPLANT_TYPE from '@salesforce/schema/Order.ImplantType__c';
import checkLogin from '@salesforce/apex/HDT_LC_CanaleContattoIVRLogin.checkLogin';
import checkContractualEnvelope from '@salesforce/apex/HDT_LC_CanaleContattoIVRLogin.checkContractualEnvelope';
import checkListenVO from '@salesforce/apex/HDT_LC_CanaleContattoIVRLogin.checkListenVo';
import checkFinalConfirmationOfTheContract from '@salesforce/apex/HDT_LC_CanaleContattoIVRLogin.checkContractualEnvelope';
import getOrderSiblings from '@salesforce/apex/HDT_LC_CanaleContattoIVRLogin.getOrderSiblings';
import getOrderSiblingsDocumentalActivity from '@salesforce/apex/HDT_LC_CanaleContattoIVRLogin.getOrderSiblingsDocumentalActivity';
import downloadFile from '@salesforce/apex/HDT_LC_CanaleContattoIVRLogin.downloadDocument';
import heralogoimg from '@salesforce/resourceUrl/heralogo';

export default class HdtCanaleContattoIVRLogin extends LightningElement {

    @track recordId;
    @track orderId;
    @track username;
    @track password;
    @track firstSectionVisible = true;
    @track secondSectionVisible = false;
    @track thirdSectionVisible = false;
    @track caseId;
    @track parentOrderId;
    @track orderSiblings = [];
    @track orderColumns;
    @track orderList = [];
    @track buttonDisabled=true;
    spinner=false;

    showTooltip = false;

    heralogo = heralogoimg;

    columnsList = [{
        label: 'Nome',
        fieldName: 'documentName',
        type: 'text'
    }, {
        label: 'Scarica il File',
        type: 'button-icon',
        initialWidth: 135,
        typeAttributes: { iconName: 'utility:download', name: 'onClickDownloadPdf', title: 'Click to download' }
    }]; 

    toggleShowPassword(event) {
        let password = this.template.querySelector('[data-id = "passwordField"]');
        password.type = password.type == 'password' ? 'text' : 'password';
    }

    handleInputChange() {

        this.username = this.template.querySelector('[data-id = "usernameField"]').value;
        this.password = this.template.querySelector('[data-id = "passwordField"]').value;

        if(this.username!='' && this.password!=''){
            this.buttonDisabled = false;
            console.log('>>> accessButton Enablebled');
        } else {
            this.buttonDisabled = true;
            console.log('>>> accessButton disabled');
        }

    }

    handleLogin(event) {

        console.log('>>> accessButton click');
        this.buttonDisabled = true;
        this.spinner=true;

        let username = this.template.querySelector('[data-id = "usernameField"]').value;
        let password = this.template.querySelector('[data-id = "passwordField"]').value;
        this.username = this.template.querySelector('[data-id = "usernameField"]').value;
        this.password = this.template.querySelector('[data-id = "passwordField"]').value;
       // console.log('prova  ' + username);
       // console.log('test  ' + password);

        if(this.username==='' || this.password===''){
            this.dispatchEvent(new ShowToastEvent({
                title: 'Attenzione!',
                message: 'Non hai inserito Username e/o Password',
                variant: 'warning'
            }));
            return;
        }

        checkLogin({
            username: username,
            password: password

        }).then(result => {

            if (result == null) {
                console.log(result);
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Errore',
                    message: 'Username e/o Password inseriti non sono corretti',
                    variant: 'error'
                }));
            } else {
                this.orderId = result.Id;
                console.log(this.orderId);
                console.log(JSON.stringify(result));
                this.secondSectionVisible = true;
                this.firstSectionVisible = false;
            }
            this.spinner=false;
        }).catch(err => {
            console.log(JSON.stringify(err));
            this.spinner=false;
        });
    }
    downloadPdf(base64String, fileName) {
        const source = `data:application/pdf;base64,${base64String}`;
        const link = document.createElement("a");
        link.href = source;
        link.download = `${fileName}.pdf`
        link.click();
      }
      downloadZip(base64String, fileName) {
        const source = `data:application/pdf;base64,${base64String}`;
        const link = document.createElement("a");
        link.href = source;
        link.download = `${fileName}.zip`
        link.click();
      }
     /*  onClickDownloadPdf(){
        let base64String = 'base64';
        this.downloadPdf(base64String,'UFJPVkFET1dOTE9BRFBST1ZB');

      }
   */
    handleContractualEnvelope(event) {


        downloadFile({orderId : this.orderId,username : this.username,password : this.password}).then(res =>{
            console.log('********:' + JSON.stringify(res));
            if(res.res == null || res.res == undefined){
            if(this.name = 'onClickDownloadPdf'){
               // let base64String = 'UFJPVkFET1dOTE9BRFBST1ZB';
                if(res.type == 'zip'){
                    this.downloadZip(res.base64,'Plico');
                }
                else if(res.type == 'pdf'){
                    this.downloadPdf(res.base64,'Plico');
                }
                else{
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Errore',
                        message: res.errorMessage,
                        variant: 'error'
                    }));
                }
            }   
            }
            else{
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Errore',
                    message: 'Si è verificato un errore!',
                    variant: 'error'
                }));
            }
        
        })
        .catch(error => {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Errore',
                message: 'Si è verificato un errore!',
                variant: 'error'
            }));
        });
        //checkContractualEnvelope({

         //   orderId: this.orderId

       // }).then(result => {
            console.log(this.orderId);
           // if (result.ParentOrder__c != null) {
               // this.parentOrderId = result.ParentOrder__c;
               // console.log(this.orderId + '1');
              /*  getOrderSiblingsDocumentalActivity({
                    parentId: this.orderId
                    
                }).then(res => {
                    console.log(this.orderId + '2');
                    if (res != null) {
                        console.log(this.orderId + ' 3');
                        res.forEach(row => {
                            console.log(this.orderId + ' 4');
                            if(row.hasOwnProperty('DocumentalActivity__c')) {
                                this.orderList.push({
                                    
                                    id: row.DocumentalActivity__c,
                                    documentName: row.DocumentalActivity__r.Name
                                });
                                console.log(row.DocumentalActivity__c + ' 7');
                            }
                        });

                        if (this.orderList.length > 0) {
                            console.log(this.orderId + ' 5');
                            this.thirdSectionVisible = true;
                            if(this.name = 'onClickDownloadPdf'){
                                let base64String = 'UFJPVkFET1dOTE9BRFBST1ZB';
                            this.downloadPdf(base64String,'sample');
                            }
                          
 
                        } else {
                            console.log(this.orderId + ' 6');
                            this.dispatchEvent(new ShowToastEvent({
                                title: 'Error',
                                message: 'No data to display',
                                variant: 'error'
                            }));
                        }
                    }
                    console.log(JSON.stringify(res));
               // }).catch(err => {
                 //   console.log(JSON.stringify(err));
               // });
                
          //  }
       // });*/
    }

 
    handleListenVO(event) {


        checkListenVO({orderId : this.orderId,username : this.username,password : this.password}).then(res => {
            console.log('#Res >>> ' + JSON.stringify(res));
            console.log('#Res[res] >>> ' + res.res);
            console.log('#Res[res] condition >>> ' + (res.res !== null && res.res !== undefined))
            if(res.res !== null && res.res !== undefined){

                // let ecid = res.ecid;
                // let token = res.token
                if(res.errorMessage == null || res.errorMessage == undefined){

                    // let searchparams2 = 'token=' + encodeURIComponent(token) +'&ecid=' + encodeURIComponent(ecid); 
                    // let reiteklink = 'https://herapresfdc.cloudando.com/HeraSfdc/rec/download?' + searchparams2;
                    console.log('#Recording Link >>> ' + res.res);
                    let reiteklink = res.res;
                    const link = document.createElement("a");
                    link.href = reiteklink;
                    link.target = '_blank';
                    link.click();
                }
                else{
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Errore',
                        message: res.errorMessage,
                        variant: 'error'
                    }));
                } 
                }
            else{
                console.log('# Else statement res null #')
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Errore',
                    message: 'Si è verificato un errore!',
                    variant: 'error'
                }));
            }
            console.log(JSON.stringify(result));
        }).catch(err => {
            console.log(JSON.stringify(err));
        });
    }

    handleFinalConfirmationOfTheContract(event) {


        checkFinalConfirmationOfTheContract({

            orderId: this.orderId,
            username: this.username,
            password: this.password

        }).then(result => {
            if(result == 'success'){
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Successo',
                    message: 'Contratto Validato',
                    variant: 'success'
                }));
            }else if(result == 'Validato'){
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Attenzione',
                    message: 'Contratto già validato in precedenza',
                    variant: 'warning'
                }));
            }
            else{
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Errore',
                    message: 'Si è verificato un errore!',
                    variant: 'error'
                }));
            }
           /* this.orderId = result;
            if (result.ParentOrder__c != null) {
                this.parentOrderId = result.ParentOrder__c;
                getOrderSiblings({
                    parentId: this.parentOrderId
                }).then(result => {
                    console.log('Id degli Figli' + JSON.stringify(result));
                }).catch(err => {
                    console.log(JSON.stringify(err));
                });
            }
            console.log('Il Padre' + result.ParentOrder__c);
            console.log(JSON.stringify(result));*/
        }).catch(err => {
            console.log(JSON.stringify(err));
        });
    }

    toggleTooltip() {
        this.showTooltip = !this.showTooltip;
    }
}