% 基础滑模控制 (SMC) 仿真
clear; clc; close all;

%% 参数设置
T = 3;             % 仿真总时长 (秒)
dt = 0.001;         % 仿真步长 (秒)


switch_track = 3;   % 0:关激励信号
                    % 1:正弦连续信号
                    % 2:正弦阶跃信号
                    % 3:变频变幅阶跃信号

switch_filter = 1;  % 0:滤波器关
                    % 1:滤波器开

switch_force = 1;   % 0:外部扰动力关
                    % 1:外部扰动力开

switch_debuge = 0;  % 0:定性分析各个状态量、相轨迹等
                    % 1：定量对比各个参数不同跟踪效果

% 基本参数
c=10;               % 滑模面参数 (决定了滑模运动时的收敛速度)，对应现实的转动惯量                 
L=20;               % 切换增益 (必须大于扰动的最大上界 L)     
alpha=4;            % 人为设计的收敛速度         
width=0.05;         % 边界层厚度 (用于平滑 sign 函数，防止仿真发散)


% SMC基本参数
c_SMC = c;                              % 滑模面参数 (决定了滑模运动时的收敛速度)，对应现实的转动惯量
L_SMC = L;                              % 切换增益 (必须大于扰动的最大上界 L)
alpha_SMC = alpha;                      % 人为设计的收敛速度
rho_SMC = L_SMC + alpha_SMC/sqrt(2);    % 综合切换增益

% QSMC参数
c_QSMC = c;                                 % 滑模面参数 (决定了滑模运动时的收敛速度)，对应现实的转动惯量
L_QSMC = L;                                 % 切换增益 (必须大于扰动的最大上界 L)
alpha_QSMC = alpha;                         % 人为设计的收敛速度
rho_QSMC = L_QSMC + alpha_QSMC/sqrt(2);     % 综合切换增益
width_QSMC = width;                         % 边界层厚度 (用于平滑 sign 函数，防止仿真发散)

% ASMC参数
c_ASMC = c;             % 滑模面参数 (决定了滑模运动时的收敛速度)，对应现实的转动惯量
c_bar_ASMC=5;           % 物理阻尼
L_ASMC=L;               % 切换增益 (必须大于扰动的最大上界 L)
L_bar_ASMC=1;           % 二阶切换增益 (必须大于扰动切换变换速率的上界L_bar)
alpha_ASMC = alpha;     % 人为设计的收敛速度
width_ASMC= width;      % 边界层厚度 (用于平滑 sign 函数，防止仿真发散)

v_ASMC = 0;             % u的导数中间变量
last_sigma_ASMC = 0;    % 离散差分中间变量

% TSMC参数
rho_TSMC = 100;         %rho充分大且能收敛
c_TSMC = c;
width_TSMC = width;
L_TSMC = L;
p_TSMC = 5;    % p%2==1 && 1>q/p
q_TSMC = 3;    % q%2==1 && 1>q/p
B_TSMC = 1;

% NTSMC参数
c_NTSMC = c;
width_NTSMC = width;
L_NTSMC = L;
p_NTSMC = 5;    % p%2==1 && 1<p/q<2
q_NTSMC = 3;    % q%2==1 && 1<p/q<2
B_NTSMC = 1;

% Full-TSMC参数
a_Full = 0.85;  % 0<a<1
c1_Full = 15;
c2_Full = 5;
Fx = 5;  % 外界扰动的上界
Dx = 10;  % 外界扰动变化率的上界
B_Full = 1;
err_spd_last_Full = 0; % 中间变量
u_n_temp = 0; % 中间变量

% ISMC参数
c_ISMC = c;                                 % 滑模面参数 (决定了滑模运动时的收敛速度)，对应现实的转动惯量
L_ISMC = L;                                 % 切换增益 (必须大于扰动的最大上界 L)
alpha_ISMC = alpha;                         % 人为设计的收敛速度
rho_ISMC = L_ISMC + alpha_ISMC/sqrt(2);     % 综合切换增益
width_ISMC= width;                          % 边界层厚度 (用于平滑 sign 函数，防止仿真发散)
c2_ISMC=80;
u1_ISMC=0;                                  % u1中间变量，用于补偿状态不在滑模面的力矩
u2_ISMC=0;                                  % u2中间变量，用于让滑模面趋近于0的力矩
z_ISMC=0;                                   % u2的积分中间量

% HONFITSMC
b_HON=1;
L_HON=L;
n_HON=80; % 正参数
lambda1_HON=100;% 正参数
lambda2_HON=15;% 正参数
e_HON=0.8; % 0<e<1;
u0_HON=20;% >0
b0_HON=20;% >0
c0_HON=0.8; % 0<c0<1
func_HON_temp=0; % 中间变量
err_spd_last_HON=0; % 中间变量

% STASMC参数
C_STA = 60;                 % 总扰动的上界
width_STA = width;          % 边界层厚度 (用于平滑 sign 函数，防止仿真发散)
c_STA = 1.5 * sqrt(C_STA);  % 中间变量
b_SAT = 1.1 * C_STA;        % 中间变量
w_STA = 0;                  % 中间变量

% FTSMC参数
c_FTSMC = c;
width_FTSMC = width;
c2_FTSMC = 2;
b_FTSMC = 2;
q_FTSMC = 1;
p_FTSMC = 3;
epsilon_FTSMC = 100;

% NFTSMC参数
alpha_NFT = 0.5;  % >0
bate_NFT  = 0.001;  % >0
r1_NFT = 1.7;      % r1>r2
r2_NFT = 1.2;     % 2>r2>1
k1_NFT = 0.01;
k2_NFT = 0.01;
xd_NFT = 0;



% 2. 状态初始化
x1 = 1;             % 初始位置 x1(0) = 1 (即距离原点 1m)
x2 = 0;             % 初始速度 x2(0) = 0
x3 = 0;
exp_acc_ave=0;
exp_spd_ave=0;
exp_pos_ave=0;

wn = 50;           % 自然频率
zeta = 0.85;          % 阻尼比
u = 0;              % 初始控制输入
exp_pos_last = 0;   % 前一帧位置变量

% 用于记录数据的数组
history_x1 = zeros(1, T/dt);    % 位置
history_x_ave = zeros(1, T/dt);
history_x2 = zeros(1, T/dt);    % 速度
history_esp = zeros(1, T/dt);   % 预期位置
history_comp0 = zeros(1, T/dt); % 位置对比0
history_comp1 = zeros(1, T/dt); % 位置对比1
history_comp2 = zeros(1, T/dt); % 位置对比2
history_sigma = zeros(1, T/dt); % sigma
history_u  = zeros(1, T/dt);    % 激励相应
history_f  = zeros(1, T/dt);    % 阻力
history_t  = 0:dt:T-dt;         % 时间t

%% 主循环数据处理代码
for k = 1:length(history_t)
    t = history_t(k);
    
    if(switch_track==1)
        % 正弦跟踪
        exp_pos = sin(t) + sin(t*2) + sin(t*3);
    elseif(switch_track==2)
        % 正弦阶跃
        period = 1/3;
        range = 1;
        t_mod = mod(t + period/2, period) - period/2;   % [-period/2, period/2)
        exp_pos = range * sin(pi * t_mod / period);         % 缩放：端点对应 ±π/2
    elseif(switch_track==3)
        % 变频幅度阶跃
        if(t<1)
            period = 1/3;
            range = 1;
        elseif(1<=t&&t<2)
            period = 2/3;
            range = 2;
        elseif(2<=t&&t<3)
            period = 1/3;
            range = 1;
        else
            period = 1/3;
            range = 1;
        end
        t_mod = mod(t + period/2, period) - period/2;   % [-period/2, period/2)
        exp_pos = range * sin(pi * t_mod / period);         % 缩放：端点对应 ±π/2
    else
        exp_pos = 0;
    end

    if(switch_filter==0)
        % 原始估计器（直接估计）
        exp_spd = (exp_pos - exp_pos_last) / dt;
        err_pos = x1 - exp_pos;
        err_spd = x2 - exp_spd;
        exp_pos_last = exp_pos;
        exp_acc_ave = 0;
    else
        % 二阶滤波器
        exp_acc_ave = wn * wn * (exp_pos-exp_pos_ave) - 2 * zeta * wn * exp_spd_ave;
        exp_spd_ave = exp_spd_ave + exp_acc_ave*dt;
        exp_pos_ave = exp_pos_ave + exp_spd_ave*dt;
        err_pos = x1 - exp_pos_ave;
        err_spd = x2 - exp_spd_ave;
        err_acc = x3 - exp_acc_ave;
    end

    %外部扰动 f(t)
    if(switch_force==0)
        f_dist=0;
    elseif(t>=1.5&&t<=2)
        f_dist = 20;
    else
        f_dist = 8 * sin(9*t); 
    end
    

    
    %% SMC 传统滑膜
    % sigma = err_spd + c_SMC * err_pos; 
    % u = -c_SMC * err_spd - rho_SMC * sign(sigma); 


    %% QSMC 准滑膜
    % sigma = err_spd + c * err_pos; 
    % u = -c * err_spd - rho_QSMC * sat(sigma,width_QSMC); 


    %% ASMC 渐进滑膜
    % sigma = err_spd + c_ASMC * err_pos;
    % sigma_s = (sigma-last_sigma_ASMC)/dt + c_bar_ASMC*sigma;
    % last_sigma_ASMC=sigma;
    % % 原版
    % % v_ASMC = - c_ASMC * c_bar_ASMC * err_spd ...
    % %     - (c_ASMC + c_bar_ASMC) * u ...
    % %     - (L_bar_ASMC + (c_ASMC + c_bar_ASMC) * L_ASMC + alpha_ASMC/sqrt(2))*sign(sigma_s + c_bar_ASMC * sigma);
    % % 平滑改进
    % v_ASMC = - c_ASMC * c_bar_ASMC * err_spd ...
    %     - (c_ASMC + c_bar_ASMC) * u ...
    %     - (L_bar_ASMC + (c_ASMC + c_bar_ASMC) * L_ASMC + alpha_ASMC/sqrt(2))*sat(sigma_s + c_bar_ASMC * sigma, width_ASMC);
    % u = u + dt * v_ASMC;



    %% TSMC 终端滑模
    % % 简单到达律形式
    % lambda_TSMC = q_TSMC / p_TSMC;
    % sigma = err_spd + c_TSMC * power(abs(err_pos), lambda_TSMC) * sign(err_pos);
    % % u = -rho_TSMC * sign(sigma);
    % u = -rho_TSMC * sat(sigma, width_TSMC);
    % 
    % % 完整到达律:等效控制+切换控制
    % lambda_TSMC = q_TSMC / p_TSMC;
    % sigma = err_spd + c_TSMC * power(abs(err_pos), lambda_TSMC) * sign(err_pos);
    % u_eq = -power(abs(err_pos), lambda_TSMC-1) * sign(err_pos) * B_TSMC * c_TSMC * lambda_TSMC * err_spd;
    % % 原版
    % % u_n = -B_TSMC * (L_TSMC + abs(u_eq)) * sign(sigma,width);
    % % 平滑改进
    % u_n = -B_TSMC * (L_TSMC + abs(u_eq)) * sat(sigma,width_TSMC);
    % u = u_eq + u_n;



    %% NTSMC 非奇异终端滑模
    % % 严格来说，NTSMC性能可能不如普通终端滑模，他是为了根除err_pos趋近于0时产生的奇异性，牺
    % % 牲了部分逼近能力，且仿真环境过于理性，不会有实际的阻力、误差、执行器饱和上限等问题。
    % lambda_NTSMC = p_NTSMC / q_NTSMC;
    % sigma = power(abs(err_spd), lambda_NTSMC) * sign(err_spd) + c_NTSMC * err_pos;
    % u_eq = -power(abs(err_spd), 2-lambda_NTSMC) * B_NTSMC * c_NTSMC / lambda_NTSMC;
    % % 原版
    % % u_n = -B_NTSMC * (L_NTSMC + abs(u_eq)) * sign(sigma,width);
    % % 平滑改进
    % u_n = -B_NTSMC * (L_NTSMC + abs(u_eq)) * sat(sigma,width_NTSMC);
    % u = u_eq + u_n;
    

    

    %% Full-TSMC 全阶终端滑膜
    % % 意在解决TSMC的奇异性和震颤问题
    % a1_Full = a_Full/(2-a_Full);
    % a2_Full = a_Full;
    % err_acc = (err_spd - err_spd_last_Full)/dt;
    % err_spd_last_Full = err_spd;
    % sigma = err_acc + ...
    %         c2_Full * power(abs(err_spd), a2_Full) * sign(err_spd) + ...
    %         c1_Full * power(abs(err_pos), a1_Full) * sign(err_pos);
    % u_eq = -(c2_Full * power(abs(err_spd), a2_Full) * sign(err_spd) + c1_Full * power(abs(err_pos), a1_Full) * sign(err_pos)) / B_Full;
    % u_n_temp = u_n_temp + (Dx+1) * sat(sigma,width) * dt;
    % u_n = -u_n_temp / B_Full;
    % u = u_eq+u_n;



    %% ISMC 积分滑膜
    % ISMC面对阶跃信号效果明显要更强，算是一个比较满意的控制算法，不论是阶跃信号还是连续信号效果都可以
    % sigma = err_spd + c_ISMC * err_pos; 
    % u2_ISMC = c2_ISMC * sigma;
    % z_ISMC = z_ISMC + u2_ISMC * dt;
    % s_ISMC = sigma - z_ISMC;
    % % 原版
    % u1_ISMC = rho_ISMC * sign(s_ISMC);
    % % 平滑改进
    % % u1_ISMC = rho_ISMC * sat(s_ISMC,width_ISMC);
    % u = -(u1_ISMC + u2_ISMC);



    %% HONFITSMC 高阶非奇异快速积分终端滑模
    % 必须开估计器，否则不收敛
    s0_HON = err_pos;
    func_HON_data = func_HON(err_pos,err_spd,u0_HON,b0_HON,c0_HON);
    func_HON_temp = func_HON_temp + func_HON_data * dt;
    s1_HON = err_spd + func_HON_temp;
    sigma=s1_HON;
    u = -(L_HON - exp_acc_ave + func_HON_data)/b_HON ...
        -n_HON * sat(s1_HON,width) ...
        -lambda1_HON * power(abs(s1_HON), e_HON) * sign(s1_HON) ...
        -lambda2_HON * s1_HON;



    %% STASMC 超螺旋滑膜
    % sigma = err_spd + c_STA * err_pos;
    % % 原版
    % % w_STA = w_STA + b_SAT * sign(sigma) * dt;
    % % u = - c_STA * sqrt(abs(sigma)) * sign(sigma) - w_STA;
    % 平滑改进
    % w_STA = w_STA + b_SAT * sat(sigma, width_STA) * dt;
    % u = - c_STA * sqrt(abs(sigma)) * sat(sigma, width_STA) - w_STA;
    


    %% FTSMC 快速中断滑膜
    % sigma = err_spd + c_FTSMC * err_pos + c2_FTSMC * power( abs(err_pos), q_FTSMC/p_FTSMC) * sign(err_pos); 
    % % 原版
    % % u = - power(b_FTSMC, -1) * ...
    % %     (c_FTSMC * err_spd + c2_FTSMC * sign(err_pos) * power(abs(max(err_pos,0.05)), q_FTSMC / p_FTSMC - 1) * err_spd + epsilon_FTSMC * sign(sigma));
    % % 平滑改进
    % u = - power(b_FTSMC, -1) * ...
    %     (c_FTSMC * err_spd + c2_FTSMC * sign(err_pos) * power(abs(max(err_pos,0.05)), q_FTSMC / p_FTSMC - 1) * err_spd + epsilon_FTSMC * sat(sigma,width_FTSMC));



    %% NFTSMC 传统滑膜
    % sigma = err_pos ...
    %     + alpha_NFT*power(abs(err_pos),r1_NFT)*sign(err_pos) ...    % 远端加速
    %     + bate_NFT*power(abs(err_spd),r2_NFT)*sign(err_spd);        % 防超调
    % u = - (1+alpha_NFT*r1_NFT*power(abs(err_pos),r1_NFT-1)) * power(abs(err_spd),2-r2_NFT) * sign(err_spd) / (bate_NFT * r2_NFT) ...
    %     - k1_NFT * sign(sigma) ...
    %     - k2_NFT * sigma ...
    %     + (err_spd - xd_NFT) / dt;
    % xd_NFT = err_spd;



    %% --- D. 记录数据 ---
    u=bound(u,6000);

    history_x1(k) = x1;
    history_x_ave(k)=exp_pos_ave;
    history_x2(k) = x2;
    history_esp(k) = exp_pos;
    history_sigma(k) = sigma;
    history_f(k) = f_dist;
    history_u(k)  = u;
    
    % 系统动力学更新
    x1_dot = x2;
    x2_dot = u + f_dist;
    
    % 更新状态，进入下一个时间步
    x1 = x1 + x1_dot * dt;
    x2 = x2 + x2_dot * dt;
    x3 = x2_dot;

end

if(switch_debuge==1)
    %% 不同参数效果对比
    figure('Name', '控制效果图', 'Position', [100 100 800 600]);
    % 图1：位置和速度收敛曲线
    subplot(3,1,1);
    plot(history_t, history_comp0, 'g-', 'LineWidth', 2); hold on;
    plot(history_t, history_esp, 'r-', 'LineWidth', 2);
    yline(0, 'k-', 'LineWidth', 1);
    title('速度位置收敛曲线');
    xlabel('时间 (s)');
    ylabel('状态量');
    legend('位置 x', '预期位置 exp', 'Location', 'best');
    grid on;

    subplot(3,1,2);
    plot(history_t, history_comp1, 'g-', 'LineWidth', 2); hold on;
    plot(history_t, history_esp, 'r-', 'LineWidth', 2);
    yline(0, 'k-', 'LineWidth', 1);
    title('速度位置收敛曲线');
    xlabel('时间 (s)');
    ylabel('状态量');
    legend('位置 x', '预期位置 exp', 'Location', 'best');
    grid on;

    subplot(3,1,3);
    plot(history_t, history_comp2, 'g-', 'LineWidth', 2); hold on;
    plot(history_t, history_esp, 'r-', 'LineWidth', 2);
    yline(0, 'k-', 'LineWidth', 1);
    title('速度位置收敛曲线');
    xlabel('时间 (s)');
    ylabel('状态量');
    legend('位置 x', '预期位置 exp', 'Location', 'best');
    grid on;
end
if(switch_debuge==0)
    %% 期望位置和实际位置对比
    figure('Name', '控制效果图', 'Position', [100 100 800 600]);
    % 图1：位置和速度收敛曲线
    subplot(1,1,1);
    plot(history_t, history_x1, 'g-', 'LineWidth', 2); hold on;
    plot(history_t, history_x_ave, 'b-', 'LineWidth', 2); hold on;
    plot(history_t, history_esp, 'r-', 'LineWidth', 2);
    yline(0, 'k-', 'LineWidth', 1);
    title('速度位置收敛曲线');
    xlabel('时间 (s)');
    ylabel('状态量');
    legend('位置 x', '预期位置 exp', 'Location', 'best');
    grid on;

    
    
    %% 速度位置收敛曲线 及 外部扰动力与抗扰动输出力矩对比
    figure('Name', 'SMC 仿真结果', 'Position', [100 100 800 600]);
    % 图1：位置和速度收敛曲线
    subplot(2,1,1);
    plot(history_t, history_x1, 'r-', 'LineWidth', 2); hold on;
    plot(history_t, history_x2, 'g-', 'LineWidth', 2);
    yline(0, 'k-', 'LineWidth', 1);
    title('速度位置收敛曲线');
    xlabel('时间 (s)');
    ylabel('状态量');
    legend('位置 x_1', '速度 x_2', 'Location', 'best');
    grid on;
    % 图2：控制输入 u(t) 的曲线
    subplot(2,1,2);
    plot(history_t, history_u, 'r-', 'LineWidth', 2);hold on;
    plot(history_t, -history_f, 'g-', 'LineWidth', 2);
    title('控制输入 u(t)');
    xlabel('时间 (s)');
    ylabel('力矩');
    legend('驱动力 u', '扰动力 f', 'Location', 'best');
    grid on;
    
    
    %% signa收敛曲线 及 滑模面逼近轨迹
    figure('Name', 'SMC 滑模面运动状态', 'Position', [100 100 800 600]);
    % 图1：位置和速度收敛曲线
    subplot(2,1,1);
    plot(history_t, history_sigma, 'w-', 'LineWidth', 2);
    title('sigma 收敛曲线');
    xlabel('时间 (s)');
    ylabel('状态量');
    grid on;
    
    % 图2：相轨迹
    subplot(2,1,2);
    % 理想轨迹
    x1_line = linspace(min(min(history_x1),-0.5), max(max(history_x1),0.5), 100); 
    x2_line_SMC = -c * x1_line; 
    x2_line_TSMC = -c * sqrt(abs(x1_line)) .* sign(x1_line);
    plot(x1_line, x2_line_SMC, 'r--', 'LineWidth', 1.5); hold on;
    plot(x1_line, x2_line_TSMC, 'b--', 'LineWidth', 1.5); hold on;
    % 实际轨迹
    plot(history_x1, history_x2, 'w-', 'LineWidth', 2);
    title('sigma 轨迹');
    xlabel('x1 (位置)');
    ylabel('x2 (速度)');
    legend('理想滑模面 (x_2 = -c x_1)', ...
        '理想滑模面 (x_2 = -c x_1^{0.5} sign(x_1))', ...
        '实际相轨迹', 'Location', 'best');
    grid on;
end

%% 功能函数
% sat斜坡函数
function data = sat(x,width)
    if(width==0)
       error("除数为0");
    end

    if(x>=width)
       data=1;
    elseif(x<=-width)
        data=-1;
    else 
        data=x/width;
    end
end


function data = bound(x,value)
    if(x>value)
        data=value;
    elseif(x<-value)
        data=-value;
    else
        data=x;
    end
end


function data = func_HON(value,value_dot,u0,b0,c0)
    r0=c0/(2-c0);
    func1 = u0 * sign(value) * ...
            power(abs(log(value + power(1 + value * value, 0.5))), r0) * ...
            power(1 + value * value, 0.5);
    func2 = b0 * power(abs(value_dot), c0) * sign(value_dot) * ...
            power(1 + value * value, (1 - c0) / 2);
    func3 = -value * value_dot * value_dot * power(1 + value * value, -1);
    data = func1 + func2 + func3;
end