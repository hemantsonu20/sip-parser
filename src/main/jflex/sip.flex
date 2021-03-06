/**
 *   Copyright 2016 Pratapi Hemant Patel
 *
 *   Licensed under the Apache License, Version 2.0 (the "License");
 *   you may not use this file except in compliance with the License.
 *   You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 *   
 */
package jflex;

import java.io.IOException;
import java_cup.sym;
import java_cup.runtime.Symbol;

/**
* A simple Lexer class to validate sip uri
* References
*
* 1. https://www.ietf.org/rfc/rfc3261.txt
* 2. https://tools.ietf.org/html/rfc5234
*
*/
%%

%class SipLexer
%unicode
%cup
%line
%column
%public

%{

      private Symbol symbol(int type, Object value) {
      	return new Symbol(type, yyline, yycolumn, value);
      }
%}


SIP_URI                  =  "sip:" {CORE_URI}
SIPS_URI                 =  "sips:" {CORE_URI}
CORE_URI                 = {userinfo}? {hostport} {uri_parameters} {headers}?

// skipping telephone_subscriber part
//userinfo               = ( {user} | {telephone_subscriber} ) ( ":" {password} )? "@"
userinfo                 = {user} ( ":" {password} )? "@"
user                     = ( {unreserved} | {escaped} | {user_unreserved} )+
password                 = ( {unreserved} | {escaped} | "&" | "=" | "+" | "$" | "," )*
unreserved               = {alphanum} | {mark}
escaped                  = "%" {HEXDIG} {HEXDIG}
user_unreserved          = "&" | "=" | "+" | "$" | "," | ";" | "?" | "/"
alphanum                 = {ALPHA} | {DIGIT}
mark                     = "-" | "_" | "." | "!" | "~" | "*" | "'" | "(" | ")"
HEXDIG                   = {DIGIT} | "A" | "B" | "C" | "D" | "E" | "F"
ALPHA                    = [a-zA-Z]
DIGIT                    = [0-9]

hostport                 =  {host} ( ":" {port} )?
host                     =  {hostname} | {IPv4address} | {IPv6reference}
hostname                 =  ( {domainlabel} "." )* {toplabel} (".")?
domainlabel              =  {alphanum} | ({alphanum} ( {alphanum} | "-" )* {alphanum})
toplabel                 =  {ALPHA} | ({ALPHA} ( {alphanum} | "-" )* {alphanum})

uri_parameters           =  ( ";" {uri_parameter})*
uri_parameter            =  {transport_param} | {user_param} | {method_param} | {ttl_param} | {maddr_param} | {lr_param} | {other_param}
transport_param          =  "transport=" ("udp" | "tcp" | "sctp" | "tls" | {other_transport})
other_transport          =  {token}
user_param               =  "user=" ( "phone" | "ip" | {other_user})
other_user               =  {token}
method_param             =  "method=" {Method}
ttl_param                =  "ttl=" {ttl}
maddr_param              =  "maddr=" {host}
lr_param                 =  "lr"
other_param              =  {pname} ( "=" {pvalue} )?
pname                    =  {paramchar}+
pvalue                   =  {paramchar}+
paramchar                =  {param_unreserved} | {unreserved} | {escaped}
param_unreserved         =  "[" | "]" | "/" | ":" | "&" | "+" | "$"
token                    =  ({alphanum} | "-" | "." | "!" | "%" | "*" | "_" | "+" | "`" | "'" | "~" )+
ttl                      =  {DIGIT}{1,3}
Method                   =  "INVITE" | "ACK" | "OPTIONS" | "BYE" | "CANCEL" | "REGISTER" | {extension_method}
extension_method         =  {token}



headers                  =  "?" {header} ( "&" {header} )*
header                   =  {hname} "=" {hvalue}
hname                    =  ( {hnv_unreserved} | {unreserved} | {escaped} )+
hvalue                   =  ( {hnv_unreserved} | {unreserved} | {escaped} )*
hnv_unreserved           =  "[" | "]" | "/" | "?" | ":" | "+" | "$"

IPv4address              =  {DIGIT}{1,3} "." {DIGIT}{1,3} "." {DIGIT}{1,3} "." {DIGIT}{1,3}
IPv6reference            =  "[" {IPv6address} "]"
IPv6address              =  {hexpart} ( ":" {IPv4address} )?
hexpart                  =  {hexseq} | ({hexseq} "::" {hexseq}?) | "::" {hexseq}?
hexseq                   =  {hex4} ( ":" {hex4})*
hex4                     =  {HEXDIG}{1,4}
port                     =  {DIGIT}+

%%

<YYINITIAL> {
  {SIP_URI}                 { return symbol(sym.ID, yytext()); }
  {SIPS_URI}                { return symbol(sym.ID, yytext()); }
}

[^]                              { throw new IOException("Illegal character <"+ yytext()+ ">"); }
