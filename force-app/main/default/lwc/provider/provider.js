/**
 * THis is provider component that's load the redux library. This will be tom most component for the lwc-redux application.
 * 
 * @author : https://github.com/chandrakiran-dev
 */

import { LightningElement, api , track} from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import runtimedependencies from '@salesforce/resourceUrl/runtimedependencies';

export default class Provider extends LightningElement {
    @api _store;
    @track loadCompleted = false;
    @api 
    get store(){
        return this._store;
    }
    set store(value){
        if(value){
            this._store = value;
        }
    }
    async connectedCallback(){
        try{
            if(!window.Redux){
                await Promise.all([
                    loadScript(this, runtimedependencies),
                ]);
            }
            this.template.addEventListener('lwcredux__getstore', this.handleGetStore.bind(this));
            this.dispatchEvent(new CustomEvent('init'));
            this.loadCompleted = true;
        }
        catch(error){
            console.error(error)
        }
    }
    handleGetStore(event){
        try{
            event.stopPropagation();
            let callback = event.detail
            callback(this._store);
        }
        catch(error){
            console.error(error)
        }
    }
    getStore(){
        return this._store;
    }
}