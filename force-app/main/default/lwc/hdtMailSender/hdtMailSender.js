import { LightningElement } from "lwc";

export default class HdtMNailSender extends LightningElement {
    mailSender = 'saleforceOrg@mail.com';
    mailReceiver = 'receiver@mail.com';
    bodyMail = '';
    temp1 = '';
    temp2 = '';
    temp3 = '';
    options = [];

    connectedCallback(){
        this.temp1 = 'Ciao Mario Rossi,<br><br>questo è il primo template';
        this.temp2 = 'Ciao Mario Rossi,<br><br>questo è il secondo template';
        this.temp3 = 'Ciao Mario Rossi,<br><br>questo è il terzo template';

        this.options.push({ label: 'Template 1', value: 'temp1' });
        this.options.push({ label: 'Template 2', value: 'temp2' });
        this.options.push({ label: 'Template 3', value: 'temp3' });

    }

    handleTemplateChange(event) {
        
        switch (event.detail.value) {
            case 'temp1':
                this.bodyMail = this.temp1;
                break;
            case 'temp2':
                this.bodyMail = this.temp2;
                break;
            case 'temp3':
                this.bodyMail = this.temp3;
        }

        this.template.querySelectorAll('button').forEach(c => {
            if(c.name === 'sendComunication'){
                if(this.bodyMail != undefined && this.bodyMail != ''){
                    c.removeAttribute('disabled'); 
                } else {
                    c.setAttribute('disabled', '');
                }
            }
        });

    }

    handleChange(event) {
        this.bodyMail = event.target.value;
    }

    handleClick(event){
        console.log('>>> send this: ' + this.bodyMail);
    }
}