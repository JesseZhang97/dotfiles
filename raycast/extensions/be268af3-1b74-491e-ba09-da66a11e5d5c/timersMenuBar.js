"use strict";var $=Object.defineProperty;var b=Object.getOwnPropertyDescriptor;var _=Object.getOwnPropertyNames;var U=Object.prototype.hasOwnProperty;var j=(e,t)=>{for(var n in t)$(e,n,{get:t[n],enumerable:!0})},H=(e,t,n,r)=>{if(t&&typeof t=="object"||typeof t=="function")for(let o of _(t))!U.call(e,o)&&o!==n&&$(e,o,{get:()=>t[o],enumerable:!(r=b(t,o))||r.enumerable});return e};var R=e=>H($({},"__esModule",{value:!0}),e);var V={};j(V,{default:()=>N});module.exports=R(V);var i=require("@raycast/api"),B=require("react");var F=require("@raycast/api"),y=require("react");var s=require("@raycast/api"),M=require("child_process"),k=require("crypto"),c=require("fs"),A=require("path");var S=e=>{let t=Math.floor(e/3600),n=String(Math.floor(e%3600/60)).padStart(2,"0"),r=String(Math.floor(e%60)).padStart(2,"0");return`${t}:${n}:${r}`};var P=e=>(e.d1=e.d1=="----"?void 0:e.d1,e.d2=e.d2=="----"?void 0:e.d2,Math.round((e.d1?new Date(e.d1):new Date).getTime()-(e.d2?new Date(e.d2):new Date).getTime())/1e3);var p=s.environment.supportPath+"/customTimers.json",w=(e=!1)=>{let t=(0,s.getPreferenceValues)();if(parseFloat(t.volumeSetting)>5){let n="\u26A0\uFE0F Timer alert volume should not be louder than 5 (it can get quite loud!)";return e?(0,s.showHUD)(n):(0,s.showToast)({style:s.Toast.Style.Failure,title:n}),!1}return!0};async function D(e,t="Untitled",n="default"){let o=(s.environment.supportPath+"/"+new Date().toISOString()+"---"+e+".timer").replace(/:/g,"__");(0,c.writeFileSync)(o,t);let l=(0,s.getPreferenceValues)(),f=`${s.environment.assetsPath+"/"+(n==="default"?l.selectedSound:n)}`,d=[`sleep ${e}`];d.push(`if [ -f "${o}" ]; then osascript -e 'display notification "Timer \\"${t}\\" complete" with title "Ding!"'`);let h=`afplay "${f}" --volume ${l.volumeSetting.replace(",",".")}`;if(l.selectedSound==="speak_timer_name"?d.push(`say "${t}"`):d.push(h),l.ringContinuously){let a=`${o}`.replace(".timer",".dismiss");(0,c.writeFileSync)(a,".dismiss file for Timers"),d.push(`while [ -f "${a}" ]; do ${h}; done`)}d.push(`rm "${o}"; else echo "Timer deleted"; fi`),(0,M.exec)(d.join(" && "),(a,g)=>{if(a){console.log(`error: ${a.message}`);return}if(g){console.log(`stderr: ${g}`);return}}),(0,s.popToRoot)(),await(0,s.showHUD)(`Timer "${t}" started for ${S(e)}! \u{1F389}`)}function x(e){let t=`if [ -f "${e}" ]; then rm "${e}"; else echo "Timer deleted"; fi`,n=e.replace(".timer",".dismiss"),r=`if [ -f "${n}" ]; then rm "${n}"; else echo "Timer deleted"; fi`;(0,M.execSync)(t),(0,M.execSync)(r)}function O(){let e=[];return(0,c.readdirSync)(s.environment.supportPath).forEach(n=>{if((0,A.extname)(n)==".timer"){let r={name:"",secondsSet:-99,timeLeft:-99,originalFile:n,timeEnds:new Date};r.name=(0,c.readFileSync)(s.environment.supportPath+"/"+n).toString();let o=n.split("---");r.secondsSet=Number(o[1].split(".")[0]);let l=o[0].replace(/__/g,":");r.timeLeft=Math.max(0,Math.round(r.secondsSet-P({d2:l}))),r.timeEnds=new Date(l),r.timeEnds.setSeconds(r.timeEnds.getSeconds()+r.secondsSet),e.push(r)}}),e.sort((n,r)=>n.timeLeft-r.timeLeft),e}function C(){(0,c.existsSync)(p)||(0,c.writeFileSync)(p,JSON.stringify({}))}function L(e){C();let t=JSON.parse((0,c.readFileSync)(p,"utf8"));t[(0,k.randomUUID)()]=e,(0,c.writeFileSync)(p,JSON.stringify(t))}function E(){return C(),JSON.parse((0,c.readFileSync)(p,"utf8"))}function v(e){C();let t=JSON.parse((0,c.readFileSync)(p,"utf8"));delete t[e],(0,c.writeFileSync)(p,JSON.stringify(t))}function I(){let[e,t]=(0,y.useState)(void 0),[n,r]=(0,y.useState)({}),[o,l]=(0,y.useState)(e===void 0),f=()=>{C();let u=O();t(u);let T=E();r(T),l(!1)};return{timers:e,customTimers:n,isLoading:o,refreshTimers:f,handleStartTimer:(u,T,J=!1)=>{w(J)&&(D(u,T),f())},handleStopTimer:u=>{t(e?.filter(T=>T.originalFile!==u.originalFile)),x(`${F.environment.supportPath}/${u.originalFile}`),f()},handleStartCT:(u,T=!1)=>{w(T)&&(D(u.timeInSeconds,u.name,u.selectedSound),f())},handleCreateCT:u=>{let T={name:u.name,timeInSeconds:u.secondsSet,selectedSound:"default"};L(T),f()},handleDeleteCT:u=>{v(u),f()}}}var m=require("react/jsx-runtime");function N(){let{timers:e,customTimers:t,isLoading:n,refreshTimers:r,handleStartTimer:o,handleStopTimer:l,handleStartCT:f}=I();(0,B.useEffect)(()=>{r(),setInterval(()=>{r()},1e3)},[]),n&&r();let d=(0,i.getPreferenceValues)();if((e==null||e.length==0||e.length==null)&&d.showMenuBarItemWhen!=="always")return null;let h=()=>{if(!(e===void 0||e?.length===0||e.length==null))return d.showTitleInMenuBar?`${e[0].name}: ~${S(e[0].timeLeft)}`:`~${S(e[0].timeLeft)}`};return(0,m.jsxs)(i.MenuBarExtra,{icon:d.showMenuBarItemWhen!=="never"?i.Icon.Clock:void 0,isLoading:n,title:h(),children:[(0,m.jsx)(i.MenuBarExtra.Item,{title:"Click running timer to stop"}),e?.map(a=>(0,m.jsx)(i.MenuBarExtra.Item,{title:a.name+": "+S(a.timeLeft)+" left",onAction:()=>l(a)},a.originalFile)),(0,m.jsx)(i.MenuBarExtra.Section,{children:Object.keys(t)?.sort((a,g)=>t[a].timeInSeconds-t[g].timeInSeconds).map(a=>(0,m.jsx)(i.MenuBarExtra.Item,{title:'Start "'+t[a].name+'"',onAction:()=>f(t[a],!0)},a))}),(0,m.jsxs)(i.MenuBarExtra.Section,{children:[(0,m.jsx)(i.MenuBarExtra.Item,{title:"Start 2 Minute Timer",onAction:()=>o(60*2,"2 Minute Timer",!0)},"2M"),(0,m.jsx)(i.MenuBarExtra.Item,{title:"Start 5 Minute Timer",onAction:()=>o(60*5,"5 Minute Timer",!0)},"5M"),(0,m.jsx)(i.MenuBarExtra.Item,{title:"Start 10 Minute Timer",onAction:()=>o(60*10,"10 Minute Timer",!0)},"10M"),(0,m.jsx)(i.MenuBarExtra.Item,{title:"Start 15 Minute Timer",onAction:()=>o(60*15,"15 Minute Timer",!0)},"15M"),(0,m.jsx)(i.MenuBarExtra.Item,{title:"Start 30 Minute Timer",onAction:()=>o(60*30,"30 Minute Timer",!0)},"30M"),(0,m.jsx)(i.MenuBarExtra.Item,{title:"Start 45 Minute Timer",onAction:()=>o(60*45,"45 Minute Timer",!0)},"45M"),(0,m.jsx)(i.MenuBarExtra.Item,{title:"Start 60 Minute Timer",onAction:()=>o(60*60,"60 Minute Timer",!0)},"60M"),(0,m.jsx)(i.MenuBarExtra.Item,{title:"Start 90 Minute Timer",onAction:()=>o(60*60*1.5,"90 Minute Timer",!0)},"90M")]}),(0,m.jsx)(i.MenuBarExtra.Section,{title:"Custom Timer",children:(0,m.jsx)(i.MenuBarExtra.Item,{title:"Start Custom Timer",onAction:async()=>await(0,i.launchCommand)({name:"startCustomTimer",type:i.LaunchType.UserInitiated})},"custom")})]})}
