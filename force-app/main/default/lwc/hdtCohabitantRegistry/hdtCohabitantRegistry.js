import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class HdtCohabitantRegistry extends LightningElement {

    @api cohabitantNumber;
    numberOfLoop;
    isModalOpen = false;
    showComponent = false;
    resultString = '';

    openModal() {
        this.isModalOpen = true;
        this.numberOfLoop = [];
        console.log('this.cohabitantNumber: ' + this.cohabitantNumber);
        for( let i=0; i<this.cohabitantNumber; i++){
            let wrp = {number:i, labelNome: 'Nome componente '+(i+1), labelCognome:'Cognome componente '+(i+1), labelCf:'Codice Fiscale componente '+(i+1)}
            this.numberOfLoop.push(wrp);
        }
        this.showComponent = true;
    }

    handleSave(){
        let isValid = false;
        this.mapInput = this.template.querySelectorAll('lightning-input');
            if([...this.mapInput].every(el=> (!el.required || el.value))){
                this.resultString = 'AC:' + '\n';
                isValid = true;
                for( let i=0; i<this.cohabitantNumber*3; i+=3){
                    if(this.mapInput[i].value){
                        this.resultString = this.resultString + this.mapInput[i].value.trim() + ' ' + this.mapInput[i+1].value.trim() + ' ' + this.mapInput[i+2].value + ';\n';
                    }
                }
                this.resultString = this.resultString + ':AC' + '\n' ;
            }else{
                isValid = false;
            }

            if(!isValid){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Attenzione',
                        message: 'Compilare tutti i campi obbligatori!',
                        variant: 'error'
                    })
                );
            }else{
                this.dispatchEvent(new CustomEvent('cohabitantchange',{detail : this.resultString}));
                this.closeModal();
            }

    }

    closeModal() {
        this.isModalOpen = false;
    }

}