function [app] = update_flow_arrival_status(app)
    flow_of_new_app = app.flow;
    [samples, packets] =get_packets_per_sample(flow_of_new_app); %same as logic used for q1 and q2
    app.samples_to_wait = samples;
    app.packets_to_add = packets;
    app.x_1 = 0;

end