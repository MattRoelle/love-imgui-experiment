(local {: vec : polar-vec2} (require :vector))
(local aabb (require :aabb))
(local lume (require :lib.lume))
(local {: layout : get-layout-rect} (require :imgui))

;; Components
(λ text [context props]
  "Basic text component"
  (let [rect (get-layout-rect context)
        alignment (or props.align :center)]
    (love.graphics.setColor (unpack props.color))
    (love.graphics.print (or props.text "nil")
                         (. rect alignment :x)
                         (. rect alignment :y))))

(λ image [context props]
  "Basic image component"
  (let [rect (get-layout-rect context)]
    (love.graphics.setColor 1 1 1 1)
    (love.graphics.push)
    (love.graphics.translate rect.center.x rect.center.y)
    (love.graphics.scale (or props.scale 1) (or props.scale 1))
    (love.graphics.draw props.image)
    (love.graphics.pop)))

(λ view [context props]
  "Basic view component"
  (when true 
    (if props.color
        (love.graphics.setColor (unpack props.color))
        (love.graphics.setColor 0.3 0.3 0.4 1))
    (love.graphics.setLineWidth 4)
    (love.graphics.rectangle :line
                            context.position.x
                            context.position.y
                            context.size.x
                            context.size.y)
    (let [rect (get-layout-rect context)]
        (love.graphics.circle :fill rect.center.x rect.center.y 6)
        (love.graphics.circle :fill rect.left-center.x rect.left-center.y 6)
        (love.graphics.circle :fill rect.right-center.x rect.right-center.y 6)
        (love.graphics.circle :fill rect.top-center.x rect.top-center.y 6)
        (love.graphics.circle :fill rect.bottom-center.x rect.bottom-center.y 6))))

(λ get-mouse-position []
  (let [(x y) (love.mouse.getPosition)]
    (vec x y)))

(λ mouse-interaction [context]
  "Returns values indicating mouse-down? and hovering? state"
  (let [mpos (get-mouse-position)
        mouse-down? (love.mouse.isDown 1)
        (sx sy) (love.graphics.transformPoint context.position.x
                                              context.position.y)
        screen-space-pos (vec sx sy)
        screen-space-size context.size
        rect (aabb screen-space-pos screen-space-size)
        hovering? (rect:contains-point? mpos)]
    (values mouse-down? hovering?)))

(λ button [?state context props]
  "An immediate mode button"
  (let [state (or ?state {:hover false})
        (mouse-down? in-range?) (mouse-interaction context)]
    (set state.hover in-range?)
    (when (and props.on-click
               in-range?
               (not state.mouse-down?)
               mouse-down?)
      (props.on-click))
    (set state.mouse-down? mouse-down?)
    (love.graphics.setColor (unpack (if state.hover
                                        [0.4 0.4 0.4 1]
                                        [0.2 0.2 0.2 1])))
    (love.graphics.rectangle :fill
                            context.position.x
                            context.position.y
                            context.size.x
                            context.size.y)
    (love.graphics.setColor 1 1 1 1)
    (love.graphics.print (or props.label "na") context.position.x context.position.y)
    state))

;; Create and manage the state for your imgui components easily yourself
(var button-state {})

(fn love.draw []
  (layout #nil {:display :flex 
                :padding (vec 0 0)}
          [[view {:color [1 1 0 1] 
                  :padding (vec 10 10)
                  :flex-direction :column
                  :display :flex}
            [[#(set button-state (button button-state $...)) 
              {:label "Immediate mode, stateful button" :on-click #(print :clicked)}]
             [view {:color [0 1 1 1]}]
             [text {:text "Flex Layout" :color [1 1 1 1]}] 
             [view {:color [0 1 1 1]}
              [[view {:color [0 1 1 1] :display :flex} 
                [[view {:color [0 1 0 1]}] 
                 [view {:color [0 1 0 1]}] 
                 [view {:color [0 1 0 1]}]]]]] 
             [view {:color [0 1 1 1]}
              [[view {:color [0 1 1 1] :display :flex} 
                [[view {:color [0 1 0 1]}] 
                 [view {:color [0 1 0 1]}] 
                 [view {:color [0 1 0 1]}] 
                 [view {:color [0 1 0 1]}] 
                 [view {:color [0 1 0 1]}]]]]] 
             [view {:color [0 1 1 1]}
              [[view {:color [0 1 1 1] :display :flex} 
                [[view {:color [0 1 0 1]}] 
                 [view {:color [0 1 0 1]}] 
                 [view {:color [0 1 0 1]}] 
                 [view {:color [0 1 0 1]}] 
                 [view {:color [0 1 0 1]}] 
                 [view {:color [0 1 0 1]}]]]]]]] 
           [view {:color [1 1 0 1] :padding (vec 10 10) :display :stack :direction :down} 
             [[view {:color [1 0 1 1] :size (vec 100 100)}]
              [view {:color [1 0 0 1] :size (vec 100 30)}]
              [view {:color [0 1 1 1] :size (vec 100 200)}]
              [view {:color [1 0 0 1] :size (vec 100 30)}]
              [view {:color [0 1 1 1] :size (vec 100 100)}]
              [view {:size (vec 300 50)
                     :color [1 1 1 1]} 
               [[text {:text "Stack Layout"
                       :size (vec 300 50)
                       :align :top-center
                       :color [1 1 1 1]}]]]]] 
           [view {:color [1 0 1 1] 
                  :padding (vec 10 10)
                  :display :absolute}
            [[view {:size (vec 100 100)
                    :color [0 0 1 1]
                    :position (vec 50 50)}]
             [text {:text "Absolute Layout"
                    :align :top-left
                    :color [1 1 1 1]}]]]])) 

(fn love.update [dt])
