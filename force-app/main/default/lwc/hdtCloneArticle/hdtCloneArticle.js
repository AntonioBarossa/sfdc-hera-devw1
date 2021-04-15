import { LightningElement, api, track } from 'lwc';
import  cloneArticle from '@salesforce/apex/HDT_LC_CloneArticle.cloneArticle';
import  redirectToArticle from '@salesforce/apex/HDT_LC_CloneArticle.redirectToArticle';
import  getRecordTypeOptions from '@salesforce/apex/HDT_LC_CloneArticle.getRecordTypeOptions';
import { NavigationMixin } from 'lightning/navigation';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class CloneKnowledgeArticle extends NavigationMixin(LightningElement) {

    @api recordId;

    title;

    @track urlname;

    picklistvalue; 

    items = [];

    regex = /[ !@#$%^&*()_+=\[\]{};':"\\|,.<>\/?]/g;


    connectedCallback(){

        //console.log('Hello94');

        this.collectPickListValues(); //Instanzia la picklist prendendo i record type della Knowledge


    }

    collectPickListValues(){

        getRecordTypeOptions().then(result => {
            
            for(let i=0; i<result.length; ++i){

                this.items = [...this.items,{value : result[i].Id, label : result[i].Name}];

            }

            this.picklistvalue = this.items[1].value; 

        }).catch(error => {

            console.log('Error in collecting picklist: ' +error);

        });


    }

    get options(){

        return this.items; //valorizza la picklist nell'LWC

    }

    handlePicklistChange(event){ 

        this.picklistvalue = event.detail.value;

    }

    navigateToArticlePage(Id){ //reindirizza alla pagina dell'articolo

        this[NavigationMixin.Navigate]({

            type:'standard__recordPage',
            attributes:{

                recordId : Id,
                objectApiName : 'Knowledge__kav',
                actionName : 'view'

            }


        });


    }




    handleTitleChange(event){ //gestisce l'input del titolo e completa l'URL automaticamente

        this.title = event.detail.value;

        this.urlname = event.detail.value;

        this.urlname = this.urlname.replace(/[^A-Z0-9]+/ig, "-");

        while(this.urlname.slice(-1) === '-'){

            this.urlname = this.urlname.slice(0, -1);

        }

    }

    handleUrlChange(event){ //gestisce l'input dell'URL

        this.urlname = event.detail.value;

        this.urlname = this.urlname.replace(this.regex, '-');

        while(this.urlname.slice(-1) === "-"){

            this.urlname = this.urlname.slice(0, -1);

        }

    }

    handleClick(){ //crea il nuovo articolo e reindirizza sulla nuova pagina

        cloneArticle({articleId : this.recordId, title : this.title, urlName : this.urlname, recordtypeId : this.picklistvalue})
        .then(result => {


            redirectToArticle({title : this.title, urlName : this.urlname}).then(result =>{

                this.navigateToArticlePage(result);

                this.dispatchEvent( //mostra messaggio di successo e ricorda di modificare il template
                    new ShowToastEvent({    
                        title: 'Articolo clonato correttamente',
                        message: 'Ricorda di adattare il template in base alle tue necessità',
                        variant: 'success',
                    }),
                );


            }).catch(error => {

                console.log('Errore redirect: ' + error);

            });

        }).catch(error =>{

            console.log('#PageErrors[0].message --> ' +error.body.pageErrors[0].message);

            var errorMessage = error.body.pageErrors[0].message;

            this.dispatchEvent( //mostra messaggio di successo e ricorda di modificare il template
                new ShowToastEvent({    
                    title: 'Articolo NON clonato correttamente',
                    message: errorMessage,
                    variant: 'error',
                }),
            );

        });


    }

}