function [L_MH,L_BACK,L_RTS,L_CTS,L_SF,L_MD,L_TB,L_ACK] = ieee11axMACParams()
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here


L_SF = 32; %SERVICE FIELD NUMBER OF BITS
L_MH = 272; %MAC HEADER NUMBER OF BITS
L_TB = 6; %TAIL BITS
L_ACK = 112; %ACK BITS
L_MD = 32; %MAC DELIMITER?
L_BACK =-1;
L_RTS = -1;
L_CTS = -1;
end