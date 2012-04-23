<?xml version="1.0" encoding="UTF-8"?>
<GestureMarkupLanguage xmlns:gml="http://gestureworks.com/gml/version/1.0">
	
	<Gesture_set gesture_set_name="n-manipulate">
		
		<Gesture id="n-drag" type="drag">
			<comment>The 'n-drag' gesture can be activated by any number of touch points. When a touch down is recognized on a touch object the position
			of the touch point is tracked. This change in the position of the touch point is mapped directly to the position of the touch object.</comment>
			<match>
				<action>
					<initial>
						<cluster point_number="0" point_number_min="1" point_number_max="5" translation_threshold="0"/>
					</initial>
				</action>
			</match>	
			<analysis>
				<algorithm>
					<library module="drag"/>
					<returns>
						<property id="drag_dx"/>
						<property id="drag_dy"/>
					</returns>
				</algorithm>
			</analysis>	
			<processing>
				<inertial_filter>
					<property ref="drag_dx" release_inertia="true" friction="0.994"/>
					<property ref="drag_dy" release_inertia="true" friction="0.994"/>
				</inertial_filter>
			</processing>
			<mapping>
				<update>
					<gesture_event>
						<property ref="drag_dx" target="x" delta_threshold="true" delta_min="0.01" delta_max="100"/>
						<property ref="drag_dy" target="y" delta_threshold="true" delta_min="0.01" delta_max="100"/>
					</gesture_event>
				</update>
			</mapping>
		</Gesture>
					
		<Gesture id="n-rotate" type="rotate">
			<match>
				<action>
					<initial>
						<cluster point_number="0" point_number_min="2" point_number_max="5" rotatation_threshold="0"/>
					</initial>
				</action>
			</match>
			<analysis>
				<algorithm>
					<library module="rotate"/>
					<returns>
						<property id="rotate_dtheta"/>
					</returns>
				</algorithm>
			</analysis>	
			<processing>
				<noise_filter>
					<property ref="rotate_dtheta"  noise_filter="true" percent="30"/>
				</noise_filter>
				<inertial_filter>
					<property ref="rotate_dtheta" release_inertia="true" friction="0.996"/>
				</inertial_filter>
			</processing>
			<mapping>
				<update>
					<gesture_event>
						<property ref="rotate_dtheta" target="rotate" delta_threshold="true" delta_min="0.1" delta_max="10"/>
					</gesture_event>
				</update>
			</mapping>
		</Gesture>
		
		<Gesture id="n-scale" type="scale">
			<match>
				<action>
					<initial>
						<cluster point_number="0" point_number_min="2" point_number_max="5" separation_threshold="0"/>
					</initial>
				</action>
			</match>
			<analysis>
				<algorithm>
					<library module="scale"/>
					<returns>
						<property id="scale_dsx"/>
						<property id="scale_dsy"/>
					</returns>
				</algorithm>
			</analysis>	
			<processing>
				<inertial_filter>
					<property ref="scale_dsx" release_inertia="true" friction="0.996"/>
					<property ref="scale_dsy" release_inertia="true" friction="0.996"/>
				</inertial_filter>
			</processing>
			<mapping>
				<update>
					<gesture_event>
						<property ref="scale_dsx" target="scaleX" func="linear" factor="0.0033" delta_threshold="true" delta_min="0.0001" delta_max="1"/>
						<property ref="scale_dsy" target="scaleY" func="linear" factor="0.0033" delta_threshold="true" delta_min="0.0001" delta_max="1"/>
					</gesture_event>
				</update>
			</mapping>
		</Gesture>
		
		<Gesture id="hold" type="hold">
			<match>
				<action>
					<initial>
						<point event_duration_threshold="200" translation_threshold="2"/>
					</initial>
				</action>
			</match>	
			<analysis>
				<algorithm>
					<library module="hold"/>
					<returns>
						<property id="hold_x"/>
						<property id="hold_y"/>
					</returns>
				</algorithm>
			</analysis>	
			<mapping>
				<update>
					<gesture_event>
						<property ref="hold_x"/>
						<property ref="hold_y"/>
					</gesture_event>
				</update>
			</mapping>
		</Gesture>
		
		<Gesture id="tap" type="tap">
			<match>
				<action>
					<initial>
						<point event_duration_threshold="250" translation_threshold="10"/>
					</initial>
				</action>
			</match>	
			<analysis>
				<algorithm>
					<library module="tap"/>
					<returns>
						<property ref="tap_x" type="tap"/>
						<property ref="tap_y" type="tap"/>
					</returns>
				</algorithm>
			</analysis>	
			<mapping>
				<update>
					<gesture_event>
						<property ref="tap_x"/>
						<property ref="tap_y"/>
					</gesture_event>
				</update>
			</mapping>
		</Gesture>
		
		<Gesture id="double_tap" type="double_tap">
			<match>
				<action>
					<initial>
						<point event_duration_threshold="250" interevent_duration_threshold="250" translation_threshold="10"/>
					</initial>
				</action>
			</match>	
			<analysis>
				<algorithm>
					<library module="double_tap"/>
					<returns>
						<property id="double_tap_x"/>
						<property id="double_tap_y"/>
					</returns>
				</algorithm>
			</analysis>	
			<mapping>
				<update>
					<gesture_event>
						<property ref="double_tap_x"/>
						<property ref="double_tap_y"/>
					</gesture_event>
				</update>
			</mapping>
		</Gesture>
		
		<Gesture id="triple_tap" type="triple_tap">
			<match>
				<action>
					<initial>
						<point event_duration_threshold="250" interevent_duration_threshold="250" translation_threshold="15"/>
					</initial>
				</action>
			</match>	
			<analysis>
				<algorithm>
					<library module="triple_tap"/>
					<returns>
						<property ref="triple_tap_x" type="triple_tap"/>
						<property ref="triple_tap_y" type="triple_tap"/>
					</returns>
				</algorithm>
			</analysis>
			<mapping>
				<update>
					<gesture_event>
						<property ref="triple_tap_x"/>
						<property ref="triple_tap_y"/>
					</gesture_event>
				</update>
			</mapping>
		</Gesture>
			
		<Gesture id="flick" type="flick">
			<match>
				<action>
					<initial>
						<cluster point_number="0" point_number_min="1" point_number_max="5" acceleration_threshold="0.1"/>
					</initial>
				</action>
			</match>
			<analysis>
				<algorithm>
					<library module="flick"/>
					<returns>
						<property ref="flick_dx" type="flick" threshold="0.01"/>
						<property ref="flick_dy" type="flick" threshold="0.01"/>
					</returns>
				</algorithm>
			</analysis>	
			<processing>
				<noise_filter>
					<property ref="flick_dx" noise_filter="false" percent="0"/>
					<property ref="flick_dy" noise_filter="false" percent="0"/>
				</noise_filter>
				<inertial_filter>
					<property ref="flick_dx" touch_inertia="true" inertial_mass="3" release_inertia="true" friction="0.98"/>
					<property ref="flick_dy" touch_inertia="true" inertial_mass="3" release_inertia="true" friction="0.98"/>
				</inertial_filter>
			</processing>
			<mapping>
				<update>
					<gesture_event>
						<property ref="flick_dx" target="" func="linear" factor="1" delta_threshold="false" delta_min="0.0001" delta_max="1"/>
						<property ref="flick_dy" target="" func="linear" factor="1" delta_threshold="flase" delta_min="0.0001" delta_max="1"/>
					</gesture_event>
				</update>
			</mapping>
		</Gesture>
			
		<Gesture id="swipe" type="swipe">
			<match>
				<action>
					<initial>
						<cluster point_number="0" point_number_min="1" point_number_max="5" acceleration_threshold="0.1"/>
					</initial>
				</action>
			</match>
			<analysis>
				<algorithm>
					<library module="swipe"/>
					<returns>
						<property ref="swipe_dx" type="swipe" threshold="0.01"/>
						<property ref="swipe_dy" type="swipe" threshold="0.01"/>
					</returns>
				</algorithm>
			</analysis>	
			<processing>
				<noise_filter>
					<property ref="swipe_dx" noise_filter="false" percent="0"/>
					<property ref="swipe_dy" noise_filter="false" percent="0"/>
				</noise_filter>
				<inertial_filter>
					<property ref="swipe_dx" release_inertia="true" friction="0.99999"/>
					<property ref="swipe_dy" release_inertia="true" friction="0.99999"/>
				</inertial_filter>
			</processing>
			<mapping>
				<update>
					<gesture_event>
						<property ref="swipe_dx" target="" func="linear" factor="1" delta_threshold="false" delta_min="0.0001" delta_max="1"/>
						<property ref="swipe_dy" target="" func="linear" factor="1" delta_threshold="false" delta_min="0.0001" delta_max="1"/>
					</gesture_event>
				</update>
			</mapping>
		</Gesture>
			
		<Gesture id="scroll" type="scroll">
			<match>
				<action>
					<initial>
						<cluster point_number="0" point_number_min="2" point_number_max="5" translation_threshold="0.01"/>
					</initial>
				</action>
			</match>
			<analysis>
				<algorithm>
					<library module="scroll"/>
					<returns>
						<property ref="scroll_dx" type="scroll"/>
						<property ref="scroll_dy" type="scroll"/>
					</returns>
				</algorithm>
			</analysis>	
			<processing>
				<noise_filter>
					<property ref="scroll_dx" noise_filter="false" percent="0"/>
					<property ref="scroll_dy" noise_filter="false" percent="0"/>
				</noise_filter>
				<inertial_filter>
					<property ref="scroll_dx" touch_inertia="true" inertial_mass="3" release_inertia="true" friction="0.99999"/>
					<property ref="scroll_dy" touch_inertia="true" inertial_mass="3" release_inertia="true" friction="0.99999"/>
				</inertial_filter>
			</processing>
			<mapping>
				<update>
					<gesture_event>
						<property ref="scroll_dx" target="" func="linear" factor="1" delta_threshold="false" delta_min="0.0001" delta_max="1"/>
						<property ref="scroll_dy" target="" func="linear" factor="1" delta_threshold="flase" delta_min="0.0001" delta_max="1"/>
					</gesture_event>
				</update>
			</mapping>
		</Gesture>
			
		<Gesture id="tilt" type="tilt">
			<match>
				<action>
					<initial>
						<cluster point_number="3" point_number_min="" point_number_max="" separation_threshold="0.01"/>
					</initial>
				</action>
			</match>
			<analysis>
				<algorithm>
					<library module="tilt"/>
					<returns>
						<property id="tilt_dx"/>
						<property id="tilt_dy"/>
					</returns>
				</algorithm>
			</analysis>	
			<processing>
				<inertial_filter>
					<property ref="tilt_dx" release_inertia="true" friction="0.99999"/>
					<property ref="tilt_dy" release_inertia="true" friction="0.99999"/>
				</inertial_filter>
			</processing>
			<mapping>
				<update>
					<gesture_event>
						<property ref="tilt_dx" target="" delta_threshold="false" delta_min="0.0001" delta_max="1"/>
						<property ref="tilt_dy" target="" delta_threshold="flase" delta_min="0.0001" delta_max="1"/>
					</gesture_event>
				</update>
			</mapping>
		</Gesture>
			
		<Gesture id="1-finger-pivot" type="pivot">
			<match>
				<action>
					<initial>
						<cluster point_number="1" point_number_min="1" point_number_max="1" rotation_threshold="0.01"/>
					</initial>
				</action>
			</match>
			<analysis>
				<algorithm>
					<library module="pivot"/>
					<returns>
						<property id="pivot_dtheta"/>
					</returns>
				</algorithm>
			</analysis>	
			<processing>
				<inertial_filter>
					<property ref="pivot_dtheta" release_inertia="false" friction="0.996"/>
				</inertial_filter>
			</processing>
			<mapping>
				<update>
					<gesture_event>
						<property ref="pivot_dtheta" target="rotate" func="linear" factor="0.000002" delta_threshold="false" delta_min="0.0001" delta_max="1"/>
					</gesture_event>
				</update>
			</mapping>
		</Gesture>
			
		<Gesture id="5-finger-orient" type="orient">
			<match>
				<action>
					<initial>
						<cluster point_number="5" point_number_min="5" point_number_max="5" rotation_threshold="0.01"/>
					</initial>
				</action>
			</match>
			<analysis>
				<algorithm>
					<library module="orient"/>
					<returns>
						<property id="orient_dx"/>
						<property id="orient_dy"/>
					</returns>
				</algorithm>
			</analysis>	
			<mapping>
				<update>
					<gesture_event>
						<property ref="orient_dx" target="" delta_threshold="false" delta_min="0.0001" delta_max="1"/>
						<property ref="orient_dy" target="" delta_threshold="flase" delta_min="0.0001" delta_max="1"/>
					</gesture_event>
				</update>
			</mapping>
		</Gesture>
			
	</Gesture_set>
	
</GestureMarkupLanguage>