import { reactive } from 'vue';
import contractABI from "../contract/contractABI.json";
import {contractAddress} from "../contract/contractConstants.js";

export const web3Provider = reactive({web3:null})
export const contract = reactive({data:null})