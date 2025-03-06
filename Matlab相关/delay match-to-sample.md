# 1. TaskObjects

## 固定点

`fix(文件名, x, y)  % x，y表示坐标（单位是degree）`

## 静止图片

图片格式为：BMP, GIF, JPG, TIF, PNG

`pic(文件名, x, y)`

`pic(文件名, x, y, c)  % c表示颜色，[r g b]，值在0-1`

`pic(文件名, x, y, w, h)  % w表示宽（单位为pixel）；h表示高`

`pic(文件名, x, y, w, h, c)`

## 动画

动画格式为：AVI, MPG

`mov(文件名, x, y)`

## 圈

`crc(r, c, f, x, y)  % r是半径（单位是degree）；c是颜色；f有2个值（0表示不填充，1表示填充）`

## 矩形

`sqr(s, c, f, x, y)  % size:1 element (square) or 2 (rectangle) in degrees`

## 声音

声音格式为：WAV, MAT

`snd(文件名)`

`snd(sin, duration, frequency)  % sin is to be typed literally；duration（单位s）；frequency（单位为Hz）`

## 刺激

`stm(port, datasource)  % port见I/O主菜单面板；datasource是MAT`

`stm(port, datasource, retriggerable)  % 2个值（0,是只能触发一次，1是可以多次触发）`

## TTL

`ttl(port)`

## 自定义

`gen(function_name)  % 用户提供MATLAB函数`

`gen(function_name, x, y)`

可以使用下面的原型：

```matlab
imdata = gen_func(TrialRecord);
imdata = gen_func(TrialRecord, MLConfig);  % MLConfig为可选项
[imdata, info] = gen_func(___);  % info.Colorkey；info.TimePerFrame（单位ms），动画每帧之间的时间；info.Looping重复动画（如果能到最后一帧）
[imdata, Xdeg, Ydeg] = gen_func(___);
[imdata, Xdeg, Ydeg, info] = gen_func(___);
```

---

注意：

1. 当TaskObject#1和TaskObject#2同时出现在一个地方，编号小的会呈现在上面
2. MAT文件一定包含2个参数“y”和“fs”，即“waveform”和“frequency”
3. 当`stm(port, datasource, retriggerable)`中的retriggerable为1时，停止刺激需要更长的时间，因为要加载waveform

# 2. dms实验（runtime library version 1）

```MATLAB
% This task requires that either an "eye" input or joystick (attached to the
% eye input channels) is available to perform the necessary responses.
%
% During a real experiment, a task such as this should make use of the
% "eventmarker" command to keep track of key actions and state changes (for
% instance, displaying or extinguishing an object, initiating a movement, etc).

if ~ML_eyepresent, error('This demo requires eye signal input. Please set it up or try the simulation mode.'); end  % 判断是否连入眼动设备。没有连入时“ML_eyepresent”为0

showcursor(false);  % remove the joystick cursor  % 可以用true和false，也可以用字符'on'和'off'
bhv_code(10,'Fix Cue',20,'Sample',30,'Delay',40,'Go',50,'Reward');  % behavioral codes

% give names to the TaskObjects defined in the conditions file:  % 具体查看条件文件里的“TaskObjects”的编号（#1、#2、#3、#4）
fixation_point = 1;
sample = 2;
target = 3;
distractor = 4;

% define time intervals (in ms):
wait_for_fix = 5000;
initial_fix = 500;
sample_time = 1000;
delay = 1000;
max_reaction_time = 2000;
hold_target_time = 500;

% fixation window (in degrees):
fix_radius = 2;
hold_radius = 2.5;

% TASK:

% initial fixation:
toggleobject(fixation_point, 'eventmarker',10);  % toggleobjects(需要切换的刺激的名字, 'eventmarker', 10)
ontarget = eyejoytrack('acquirefix', fixation_point, fix_radius, wait_for_fix);  % 一般会定义一个变量名为“ontarget”，即中靶行为，ontarget = eyejoytrack()，如果眼动按任务完成则ontarget的值不为0，如果没按任务完成则ontarget值为0
if ~ontarget  % ~表示“非”
    toggleobject(fixation_point);
    trialerror(4);  % no fixation
    return
end
ontarget = eyejoytrack('holdfix', fixation_point, hold_radius, initial_fix);
if ~ontarget
    toggleobject(fixation_point);
    trialerror(3);  % broke fixation
    return
end

% sample epoch
toggleobject(sample, 'eventmarker',20);  % turn on sample
ontarget = eyejoytrack('holdfix', fixation_point, hold_radius, sample_time);
if ~ontarget
    toggleobject([fixation_point sample]);
    trialerror(3);  % broke fixation
    return
end
toggleobject(sample, 'eventmarker',30);  % turn off sample

% delay epoch
ontarget = eyejoytrack('holdfix', fixation_point, hold_radius, delay);
if ~ontarget
    toggleobject(fixation_point);
    trialerror(3);  % broke fixation
    return
end

% choice presentation and response
toggleobject([fixation_point target distractor], 'eventmarker',40);  % simultaneously turns of fix point and displays target & distractor
chosen_target = eyejoytrack('acquirefix', [target distractor], fix_radius, max_reaction_time);
if ~chosen_target
    toggleobject([target distractor]);
    trialerror(2);  % no or late response (did not land on either the target or distractor)
    return
end

% hold the chosen target
if 1==chosen_target
    toggleobject(distractor);
    ontarget = eyejoytrack('holdfix', target, hold_radius, hold_target_time);
else
    toggleobject(target);
    ontarget = eyejoytrack('holdfix', distractor, hold_radius, hold_target_time);
end
toggleobject([target distractor],'status','off');
if ~ontarget
    trialerror(5);  % broke fixation
    return
end

% reward
if 1==chosen_target
    trialerror(0);  % correct
    goodmonkey(100, 'juiceline',1, 'numreward',2, 'pausetime',500, 'eventmarker',50); % 100 ms of juice x 2
else
    trialerror(6);  % chose the wrong (second) object among the options [target distractor]
    idle(700);
end

```

# 3. dms实验（runtime library version 2）

```matlab
if ~exist('eye_','var'), error('This demo requires eye signal input. Please set it up or try the simulation mode.'); end

showcursor(false);  % remove the joystick cursor
bhv_code(10,'Fix Cue',20,'Sample',30,'Delay',40,'Go',50,'Reward');  % behavioral codes

% give names to the TaskObjects defined in the conditions file:
fixation_point = 1;
sample = 2;
target = 3;
distractor = 4;

% define time intervals (in ms):
wait_for_fix = 5000;
initial_fix = 500;
sample_time = 1000;
delay = 1000;
max_reaction_time = 2000;
hold_target_time = 500;

% fixation window (in degrees):
fix_radius = 2;
hold_radius = 2.5;

% scene 1: fixation
fix1 = SingleTarget(eye_);
fix1.Target = fixation_point;
fix1.Threshold = fix_radius;
wth1 = WaitThenHold(fix1);
wth1.WaitTime = wait_for_fix;
wth1.HoldTime = initial_fix;
scene1 = create_scene(wth1,fixation_point);

% scene 2: sample
fix2 = SingleTarget(eye_);
fix2.Target = sample;
fix2.Threshold = hold_radius;
wth2 = WaitThenHold(fix2);
wth2.WaitTime = 0;
wth2.HoldTime = sample_time;
scene2 = create_scene(wth2,[fixation_point sample]);

% scene 3: delay
wth3 = WaitThenHold(fix2);
wth3.WaitTime = 0;
wth3.HoldTime = delay;
scene3 = create_scene(wth3,fixation_point);

% scene 4: choice
mul4 = MultiTarget(eye_);
mul4.Target = [target distractor];
mul4.Threshold = fix_radius;
mul4.WaitTime = max_reaction_time;
mul4.HoldTime = hold_target_time;
mul4.TurnOffUnchosen = true;
scene4 = create_scene(mul4,[target distractor]);

% scene 5: clear the screen. equivalent to idle(0)
tc5 = TimeCounter(null_);
tc5.Duration = 0;
endscene = create_scene(tc5);

% TASK:
run_scene(scene1,10);
if ~wth1.Success
    run_scene(endscene);
    if wth1.Waiting
        trialerror(4); % no fixation
    else
        trialerror(3); % broke fixation
    end
    return
end

run_scene(scene2,20);
if ~wth2.Success
    run_scene(endscene);
    trialerror(3); % broke fixation
    return
end

run_scene(scene3,30);
if ~wth3.Success
    run_scene(endscene);
    trialerror(3); % broke fixation
    return
end

run_scene(scene4,40);
if ~mul4.Success
    run_scene(endscene);
    if mul4.Waiting
        trialerror(2); % no or late response (did not land on either the target or distractor)
    else
        trialerror(5);  % broke fixation
    end
    return
end

run_scene(endscene);

% reward
if target==mul4.ChosenTarget
    trialerror(0); % correct
    goodmonkey(100, 'juiceline',1, 'numreward',2, 'pausetime',500, 'eventmarker',50); % 100 ms of juice x 2
else
    trialerror(6); % chose the wrong (second) object among the options [target distractor]
    idle(700);
end

```

